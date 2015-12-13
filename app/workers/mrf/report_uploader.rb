module Mrf
  class ReportUploader < ::ReportUploader
    helper Mrf::ReportHelper
    
    def get_norm_buckets(report_data)
      @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                        order: "weight ASC", query_options: {
                          company_id: report_data[:company_id]
                        }).all
      
      if @norm_buckets.empty?
        @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                        order: "weight ASC", query_options: {
                          company_id: nil
                        }).all
      end
      @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
      
      @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                        order: "min_val ASC", query_options: {
                          company_id: report_data[:company_id]
                        }).all
    
      if @trait_graph_buckets.empty?
        @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                        order: "min_val ASC", query_options: {
                          company_id: nil
                        }).all
      end
      
      @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: report_data[:company_id]
                      }).all
    
      if @competency_graph_buckets.empty?
        @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                        order: "min_val ASC", query_options: {
                          company_id: nil
                        }).all
      end
    end

    def perform(report_data, auth_token, patch = {})
      tries = 0

      report_data = HashWithIndifferentAccess.new report_data
      report_id = report_data["id"]
      begin
        RequestStore.store[:auth_token] = get_token({ auth_token: auth_token }).token
        puts "Getting Report #{report_id}"
        @report = Vger::Resources::Mrf::Report.find(report_id, report_data)
        
        @assessment = Vger::Resources::Mrf::Assessment.find(@report.assessment_id, company_id: report_data[:company_id])
        
        @report.report_hash = @report.report_data
        
        Vger::Resources::Mrf::Report.save_existing(report_id,
          :status => Vger::Resources::Mrf::Report::Status::UPLOADING
        )
        
        get_norm_buckets(report_data)

        template = @report.report_data[:assessment][:use_competencies] ? "competency_report" : "fit_report"

        report_status = {
          :errors => [],
          :message => "",
          :status => "success"
        }
        
        @view_mode = "html"
        html = render_to_string(
           template: "mrf/assessments/reports/#{template}.html.haml",
           layout: "layouts/mrf/reports.html.haml",
           handlers: [ :haml ],
           formats: [ :html ]
        )
        
        @view_mode = "pdf"
        pdf = WickedPdf.new.pdf_from_string(
          render_to_string(
            "mrf/assessments/reports/#{template}.pdf.haml",
            layout: "layouts/mrf/reports.pdf.haml",
            handlers: [ :haml ],
            formats: [:pdf]
          ),
          margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
          footer: {
            :content => render_to_string("shared/reports/pdf/_report_footer.pdf.haml",layout: "layouts/mrf/reports.pdf.haml")
          }
        )


        FileUtils.mkdir_p(Rails.root.join("tmp"))
        html_file_id = "mrf_report_#{@report.id}.html"      
        html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

        pdf_file_id = "mrf_report_#{@report.id}.pdf"
        pdf_save_path = File.join(Rails.root.to_s,'tmp',"#{pdf_file_id}")

        File.open(html_save_path, 'wb') do |file|
          file << html
        end
        File.open(pdf_save_path, 'wb') do |file|
          file << pdf
        end
        
        html_s3 = upload_file_to_s3("mrf_reports/html/#{html_file_id}",html_save_path)
        pdf_s3 = upload_file_to_s3("mrf_reports/pdf/#{pdf_file_id}",pdf_save_path)
    
        Vger::Resources::Mrf::Report.save_existing(report_id,
          :html_key => html_s3[:key],
          :pdf_key => pdf_s3[:key],
          :html_bucket => html_s3[:bucket],
          :pdf_bucket => pdf_s3[:bucket],
          :status => Vger::Resources::Mrf::Report::Status::UPLOADED
        )
        
        File.delete(html_save_path)
        File.delete(pdf_save_path)
       
        JombayNotify::Email.create_from_mail(SystemMailer.send_mrf_report(@report.id, @report.report_data), "send_mrf_report")
    
      
      rescue Exception => e
        Rails.logger.debug e.message
        puts e.message
        tries = tries + 1
        if tries < 5
          retry
        else
          Vger::Resources::Mrf::Report.save_existing(report_id,
            :status => Vger::Resources::Mrf::Report::Status::FAILED
          ) rescue nil
        end
        JombayNotify::Email.create_from_mail(SystemMailer.notify_report_status("MRF Report Uploader","Failed to upload MRF report {report_id}",{
          :report => {
            :status => "Failed",
            :report_id => report_id,
            :assessment_id => report_data[:assessment_id],
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
