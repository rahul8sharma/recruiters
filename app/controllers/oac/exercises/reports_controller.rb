class Oac::Exercises::ReportsController < ApplicationController
  before_filter :authenticate_user!, except: [:s3_report]
  before_filter :get_company

  def report
    report_type = params[:report_type] || "fit_report"
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
    
    @report = Vger::Resources::Oac::UserExerciseReport.find(params[:report_id])
    @report.report_hash = @report.report_data
    
    @assessment = Vger::Resources::Oac::Exercise.find(params[:id])
    
    @report.report_configuration = @assessment.report_configuration
    
    if params[:view_mode]
      @view_mode = params[:view_mode]
    else
      if request.format == "application/pdf"
        @view_mode = "pdf"
      else  
        @view_mode = "html"
      end
    end

    template = "super_competency_report"    
    layout = "layouts/oac/reports"
    cover, toc = nil
    if @assessment.enable_table_of_contents
      cover =  oac_report_cover_url(:report_id => @report.id)
      toc = {
        disable_dotted_lines: true,
        disable_toc_links: true,
        level_indentation: 3,
        text_size_shrink: 0.5,
        margin: { left: "5mm", right: "5mm" },
        xsl_style_sheet: "#{Rails.root.to_s}/public/stylesheets/toc.xsl"
      }
    end
    @page = 1
    respond_to do |format|
      format.html { 
        render :template => "oac/exercises/reports/#{template}",
        layout: layout,
        formats: [:pdf, :html]
      }
      format.pdf {
        render pdf: "report_#{params[:report_id]}",
        footer: {
          :html => {
            template: "shared/reports/pdf/_oac_report_footer"
          }
        },
        cover: cover,
        toc: toc,
        template: "oac/exercises/reports/#{template}",
        layout: layout,
        handlers: [ :haml ],
        margin: { :left => 0, :right => 0, :top => 0, :bottom => 8 },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end


  def s3_report
    report = Vger::Resources::Oac::UserExerciseReport.find(params[:report_id], params)
    if request.format.to_s == "application/pdf"
      url = S3Utils.get_url(report.pdf_bucket, report.pdf_key)
    else
      url = S3Utils.get_url(report.html_bucket, report.html_key)
    end
    redirect_to url
  end

  protected
  
  def get_norm_buckets
    @norm_buckets = Vger::Resources::Suitability::NormBucket.where(
                      order: "weight ASC").all
    
    if @norm_buckets.empty?
      @norm_buckets = Vger::Resources::Suitability::NormBucket.where(
                      order: "weight ASC").all
    end
  end

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  # def get_assessment
  #   if params[:id].present?
  #     @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
  #   else
  #     @assessment = Vger::Resources::Mrf::Assessment.new
  #   end
  # end

end
