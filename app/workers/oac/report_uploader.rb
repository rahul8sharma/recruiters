module Oac
  class ReportUploader < ::ReportUploader
    helper Oac::ReportHelper
    
    def get_norm_buckets
      @norm_buckets = Vger::Resources::Suitability::NormBucket\
                        .where(order: "weight ASC")\
                        .all
    end

    def get_oac_score_buckets
      @score_buckets = Vger::Resources::Suitability::SuperCompetencyScoreBucket\
                          .where(order: "min_val ASC").all
      @score_buckets_by_id = Hash[@score_buckets.collect{|score_bucket| [score_bucket.id,score_bucket] }]
      
      @combined_score_buckets = Vger::Resources::Oac::CombinedSuperCompetencyScoreBucket\
                                  .where(order: "min_val ASC").all
      
      @combined_score_buckets_by_id = Hash[@combined_score_buckets\
        .collect{|score_bucket| [score_bucket.id,score_bucket] }
      ]
    end

    def upload_report
      report_id = @report_attributes["id"]
      puts "Getting Report #{report_id}"
      @report = Vger::Resources::Oac::UserExerciseReport.find(report_id, @report_attributes.merge({
        methods: [:pdf_file_name]
      }))
      @report.report_hash = @report.report_data
      
      Vger::Resources::Oac::UserExerciseReport.save_existing(report_id,
        status: Vger::Resources::Oac::UserExerciseReport::Status::UPLOADING
      )
      
      @exercise = @assessment = Vger::Resources::Oac::Exercise.find(
        @report_attributes['exercise_id']
      )
      
      get_norm_buckets
      get_oac_score_buckets
      
      cover, toc = nil
      if @assessment.enable_table_of_contents
        @report.report_configuration["pdf"]["sections"].delete_if do |section|
          section['id'] == 'pdf_cover_page'
        end
        cover =  oac_report_cover_url(report_id: @report.id).gsub("http://", '')
        toc = {
          disable_dotted_lines: true,
          disable_toc_links: true,
          level_indentation: 3,
          text_size_shrink: 0.5,
          margin: { left: "5mm", right: "5mm" },
          xsl_style_sheet: "#{Rails.root.to_s}/public/stylesheets/toc.xsl"
        }
      end

      report_status = {
        errors: [],
        message: "",
        status: "success"
      }

      @view_mode = "html"        
      template = "super_competency_report"
      layout = "layouts/oac/reports.#{@view_mode}.haml"
      
      html = ApplicationController.render(
         template: "oac/exercises/reports/#{template}.html.haml",
         layout: layout,
         handlers: [ :haml ],
         formats: [ :html ],
         assigns: { report: @report, view_mode: @view_mode, 
         assessment: @assessment, exercise: @exercise, 
         report_attributes: @report_attributes,
         norm_buckets: @norm_buckets,
         score_buckets: @score_buckets,
         combined_score_buckets: @combined_score_buckets,
         score_buckets_by_id: @score_buckets_by_id,
         combined_score_buckets_by_id: @combined_score_buckets_by_id
        }
      )
      
      @view_mode = "pdf"
      layout = "layouts/oac/reports.#{@view_mode}.haml"
      pdf = WickedPdf.new.pdf_from_string(
        ApplicationController.render(
          "oac/exercises/reports/#{template}.pdf.haml",
          layout: layout,
          handlers: [ :haml ],
          formats: [:pdf],
          assigns: { report: @report, view_mode: @view_mode, 
          assessment: @assessment, exercise: @exercise, 
          report_attributes: @report_attributes,
          norm_buckets: @norm_buckets,
          score_buckets: @score_buckets,
          combined_score_buckets: @combined_score_buckets,
          score_buckets_by_id: @score_buckets_by_id,
          combined_score_buckets_by_id: @combined_score_buckets_by_id
        ),
        margin: pdf_margin,
        footer: {
          content: ApplicationController.render(
            "shared/reports/pdf/_oac_report_footer.pdf.haml",
            layout: "layouts/mrf/reports.pdf.haml",
            assigns: { report: @report, view_mode: @view_mode, 
            assessment: @assessment, exercise: @exercise, 
            report_attributes: @report_attributes,
            norm_buckets: @norm_buckets,
            score_buckets: @score_buckets,
            combined_score_buckets: @combined_score_buckets,
            score_buckets_by_id: @score_buckets_by_id,
            combined_score_buckets_by_id: @combined_score_buckets_by_id
          )
        },
        cover: cover,
        toc: toc
      )

      FileUtils.mkdir_p(Rails.root.join("tmp"))
      html_file_id = "vdc_report_#{@report.id}.html"      
      html_save_path = File.join(Rails.root.to_s,'tmp',"#{html_file_id}")

      pdf_file_id = @report.report_data[:pdf_file_name] || @report.pdf_file_name
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
        html_key: html_s3[:key],
        html_bucket: html_s3[:bucket],
        pdf_key: pdf_s3[:key],
        pdf_bucket: pdf_s3[:bucket],
        status: status
      )
      
      File.delete(html_save_path)
      File.delete(pdf_save_path)
      mail = SystemMailer.send_oac_report(@report.id, @report.report_data)
      JombayNotify::Email.create_from_mail(mail, "send_oac_report")
    end
    
    def set_report_status_to_failed
      Vger::Resources::Oac::UserExerciseReport.save_existing(
        @report_attributes[:id],
        status: Vger::Resources::Oac::UserExerciseReport::Status::FAILED
      )
    end
    
    def error_email_subject
      "Failed to upload OAC report #{@report_attributes[:id]}"      
    end
  end
end
