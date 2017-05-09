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

    def upload_report
      report_id = @report_attributes["id"]
      puts "Getting Report #{report_id}"
      @report = Vger::Resources::Oac::UserExerciseReport.find(report_id, @report_attributes)
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
      template = "super_competency_report"
      layout = "layouts/oac/reports.#{@view_mode}.haml"
      
      html = render_to_string(
         template: "oac/exercises/reports/#{template}.html.haml",
         layout: layout,
         handlers: [ :haml ],
         formats: [ :html ]
      )
      
      @view_mode = "pdf"
      layout = "layouts/oac/reports.#{@view_mode}.haml"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "oac/exercises/reports/#{template}.pdf.haml",
          layout: layout,
          handlers: [ :haml ],
          formats: [:pdf]
        ),
        margin: { :left => 0,:right => 0, :top => 0, :bottom => 12 },
        footer: {
          :content => render_to_string("shared/reports/pdf/_oac_report_footer.pdf.haml",layout: "layouts/mrf/reports.pdf.haml")
        },
        zoom: 1.5
      )

      FileUtils.mkdir_p(Rails.root.join("tmp"))
      html_file_id = "vdc_report_#{@report.id}.html"      
      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

      pdf_file_id = "vdc_report_#{@report.id}.pdf"
      pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")

      File.open(html_save_path, 'wb') do |file|
        file << html
      end
      
      File.open(pdf_save_path, 'wb') do |file|
        file << pdf
      end
      
      html_s3 = upload_file_to_s3("oac_reports/html/#{html_file_id}",html_save_path)
      pdf_s3 = upload_file_to_s3("oac_reports/pdf/#{pdf_file_id}",pdf_save_path)
      
      if @report.report_data[:show_report]
        status = Vger::Resources::Oac::UserExerciseReport::Status::UPLOADED
      else
        status = Vger::Resources::Oac::UserExerciseReport::Status::REVIEW
      end  
  
      Vger::Resources::Oac::UserExerciseReport.save_existing(report_id,
        :html_key => html_s3[:key],
        :html_bucket => html_s3[:bucket],
        :pdf_key => pdf_s3[:key],
        :pdf_bucket => pdf_s3[:bucket],
        :status => status
      )
      
      File.delete(html_save_path)
      File.delete(pdf_save_path)
      mail = SystemMailer.send_oac_report(@report.id, @report.report_data)
      JombayNotify::Email.create_from_mail(mail, "send_oac_report")
    end
    
    def set_report_status_to_failed
      Vger::Resources::Oac::UserExerciseReport.save_existing(
        @report_attributes[:id],
        :status => Vger::Resources::Oac::UserExerciseReport::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload OAC report {@report_attributes[:id]}"      
    end
  end
end
