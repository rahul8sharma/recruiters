class Oac::Exercises::ReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter { authorize_user!(params[:company_id]) }
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
    
    if request.format == "application/pdf"
      @view_mode = "pdf"
    else  
      @view_mode = "html"
    end

    template = "competency_report.#{@view_mode}.haml"    
    layout = "layouts/oac/reports.#{@view_mode}.haml"
    
    @page = 1
    respond_to do |format|
      format.html { 
        render :template => "oac/exercises/reports/#{template}",
        layout: layout,
        formats: [:pdf, :html]
      }
      format.pdf {
        render pdf: "report_#{params[:id]}.pdf",
        footer: {
          :html => {
            template: "shared/reports/pdf/_report_footer.pdf.haml"
          }
        },
        template: "oac/exercises/reports/#{template}",
        layout: layout,
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end


  def s3_report
    report = Vger::Resources::Oac::Report.find(params[:report_id], params)
    url = S3Utils.get_url(report.html_bucket, report.html_key)
    # if request.format.to_s == "application/pdf"
    #   url = S3Utils.get_url(report.pdf_bucket, report.pdf_key)
    # else
    #   url = S3Utils.get_url(report.html_bucket, report.html_key)
    # end
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
