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

    def upload_report
      report_id = @report_attributes["id"]
      puts "Getting Report #{report_id}"
      @report = Vger::Resources::Mrf::Report.find(report_id, @report_attributes)
      
      @assessment = Vger::Resources::Mrf::Assessment.find(
        @report.assessment_id, 
        company_id: @report_attributes[:company_id]
      )
      
      @report.report_hash = @report.report_data
      
      user_name = @report.report_hash[:user][:name]
      assessment_name = @report.report_hash[:assessment][:name]
      company_name = @report.report_hash[:company][:name]
      
      Vger::Resources::Mrf::Report.save_existing(report_id,
        status: Vger::Resources::Mrf::Report::Status::UPLOADING
      )
      
      get_norm_buckets(@report_attributes)

      template = @report.report_data[:assessment][:use_competencies] ? "competency_report" : "fit_report"

      report_status = {
        errors: [],
        message: "",
        status: "success"
      }
      
      @view_mode = "html"
      html = render_to_string(
         template: "mrf/assessments/reports/#{template}",
         layout: "layouts/mrf/reports",
         formats: [ :html ]
      )
      
      @view_mode = "pdf"
      pdf = WickedPdf.new.pdf_from_string(
        render_to_string(
          "mrf/assessments/reports/#{template}",
          layout: "layouts/mrf/reports",
          formats: [:pdf]
        ),
        margin: pdf_margin,
        footer: {
          content: render_to_string(
            "shared/reports/pdf/_report_footer",
            layout: "layouts/mrf/reports",
            formats: [:pdf]
          )
        }
      )


      FileUtils.mkdir_p(Rails.root.join("tmp"))
      file_id = "#{safe_name(user_name)}-#{safe_name(assessment_name)}-#{safe_name(company_name)}-#{@report.id}"
      html_file_id = "#{file_id}.html"
      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")
      
      pdf_file_id = "#{file_id}.pdf"
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
        html_key: html_s3[:key],
        pdf_key: pdf_s3[:key],
        html_bucket: html_s3[:bucket],
        pdf_bucket: pdf_s3[:bucket],
        status: Vger::Resources::Mrf::Report::Status::UPLOADED
      )
      
      File.delete(html_save_path)
      File.delete(pdf_save_path)
     
      JombayNotify::Email.create_from_mail(SystemMailer.send_mrf_report(@report.id, @report.report_data), "send_mrf_report")
    end
    
    def set_report_status_to_failed
      Vger::Resources::Mrf::Report.save_existing(
        @report_attributes[:id],
        status: Vger::Resources::Mrf::Report::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload MRF report #{@report_attributes[:id]}"
    end
  end
end
