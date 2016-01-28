module Oac
  class ReportUploader < ::ReportUploader
    helper Oac::ReportHelper
    
    def get_norm_buckets
      @norm_buckets = Vger::Resources::Suitability::NormBucket.where(
                        order: "weight ASC").all
      
      if @norm_buckets.empty?
        @norm_buckets = Vger::Resources::Suitability::NormBucket.where(
                        order: "weight ASC").all
      end
    end

    def get_oac_score_buckets
      @score_buckets = Vger::Resources::Suitability::SuperCompetencyScoreBucket\
                            .where(
                              query_options: {
                                company_id: nil
                              },
                              order: "weight ASC"
                            ).all
      @score_buckets_by_id = Hash[@score_buckets.collect{|score_bucket| [score_bucket.id,score_bucket] }]
      
      @combined_score_buckets = Vger::Resources::Oac::CombinedSuperCompetencyScoreBucket\
                            .where(
                              query_options: {
                                company_id: nil
                              },
                              order: "weight ASC"
                            ).all
      @combined_score_buckets_by_id = Hash[@combined_score_buckets.collect{|score_bucket| [score_bucket.id,score_bucket] }]
    end

    def perform(report_data, auth_token, patch = {})
      tries = 0
      report_data = HashWithIndifferentAccess.new report_data
      report_id = report_data["id"]

      begin
        RequestStore.store[:auth_token] = get_token({ auth_token: auth_token }).token
        puts "Getting Report #{report_id}"
        @report = Vger::Resources::Oac::UserExerciseReport.find(report_id, report_data)
        @report.report_hash = @report.report_data
        Vger::Resources::Oac::UserExerciseReport.save_existing(report_id,
          :status => Vger::Resources::Oac::UserExerciseReport::Status::UPLOADING
        )
        
        get_norm_buckets
        get_oac_score_buckets

        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }

        @view_mode = "html"        
        template = "super_competency_report.#{@view_mode}.haml"
        layout = "layouts/oac/reports.#{@view_mode}.haml"
        
        html = render_to_string(
           template: "oac/exercises/reports/#{template}",
           layout: layout,
           handlers: [ :haml ],
           formats: [ :html ]
        )
        
        @view_mode = "pdf"
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string(
            "oac/exercises/reports/#{template}.pdf.haml",
            layout: layout,
            handlers: [ :haml ],
            formats: [:pdf]
          ),
          margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
          footer: {
            :content => render_to_string("shared/reports/pdf/_report_footer.pdf.haml",layout: "layouts/mrf/reports.pdf.haml")
          }
        )

        FileUtils.mkdir_p(Rails.root.join("tmp"))
        html_file_id = "oac_report_#{@report.id}.html"      
        html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

        pdf_file_id = "oac_report_#{@report.id}.pdf"
        pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")

        File.open(html_save_path, 'wb') do |file|
          file << html
        end
        
        File.open(pdf_save_path, 'wb') do |file|
          file << pdf
        end
        
        html_s3 = upload_file_to_s3("oac_reports/html/#{html_file_id}",html_save_path)
        pdf_s3 = upload_file_to_s3("oac_reports/pdf/#{pdf_file_id}",pdf_save_path)
    
        Vger::Resources::Oac::UserExerciseReport.save_existing(report_id,
          :html_key => html_s3[:key],
          :html_bucket => html_s3[:bucket],
          :status => Vger::Resources::Oac::UserExerciseReport::Status::UPLOADED
        )
        
        File.delete(html_save_path)
        File.delete(pdf_save_path)
        mail = SystemMailer.send_oac_report(@report.id, @report.report_data)
        JombayNotify::Email.create_from_mail(mail, "send_oac_report")
    
      
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Oac::UserExerciseReport.save_existing(report_id,
            :status => Vger::Resources::Oac::UserExerciseReport::Status::FAILED
          ) rescue nil
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("OAC Report Uploader","Failed to upload OAC report {report_id}",{
          :report => {
            :status => "Failed",
            :report_id => report_id,
            :exercise_id => report_data[:exercise_id],
            :company_id => report_data[:company_id]
          },
          :errors => {
            :backtrace => [e.message] + e.backtrace[0..20]
          }
        }), "notify_report_status")
      end
    end
  end
end
