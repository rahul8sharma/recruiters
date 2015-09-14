class Mrf::Assessments::ReportsController < ApplicationController
  before_filter :get_company, except: [:s3_report]
  before_filter :get_assessment, except: [:s3_report]
  
  def report
    report_type = params[:report_type] || "fit_report"  
    get_norm_buckets
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
    @report = Vger::Resources::Mrf::Report.find(params[:report_id], params) 
    @report.report_hash = @report.report_data

    Rails.logger.debug("Report Data")
    Rails.logger.debug(params)

    if params[:view_mode]
      @view_mode = params[:view_mode]
    else
      if request.format == "application/pdf"
        @view_mode = "pdf"
      else  
        @view_mode = "html"
      end
    end
    if @report.report_data[:assessment][:use_competencies]
      template = "competency_report.#{@view_mode}.haml"
    else
      template = "fit_report.#{@view_mode}.haml" 
    end  
    layout = "layouts/mrf/reports.#{@view_mode}.haml"
    @page = 1
    respond_to do |format|
      format.html { 
        render :template => "mrf/assessments/reports/#{template}",
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
        template: "mrf/assessments/reports/#{template}",
        layout: layout,
        handlers: [ :haml ],
        margin: { :left => "0mm",:right => "0mm", :top => "0mm", :bottom => "12mm" },
        formats: [:pdf],
        locals: { :@view_mode => "pdf" }
      }
    end
  end

  def report_preview
    report_type = "competency"
    get_norm_buckets        
    report_params = {}
    report_params[:company_id] = 2
    #competency
    # report_params[:assessment_id] = 322
    # report_params[:candidate_id] = 51216
    # report_params[:id] = 981    
    
    #fit
    report_params[:assessment_id] = 324
    report_params[:candidate_id] = 52675
    report_params[:id] = 987    
    
    @report_configuration = HashWithIndifferentAccess.new JSON.parse(params[:config])
    
    Rails.logger.ap("PARAMS")
    Rails.logger.ap(params[:config])
    Rails.logger.ap(@report_configuration)
    
    @norm_buckets_by_id = Hash[@norm_buckets.collect{|norm_bucket| [norm_bucket.id,norm_bucket] }]
    @report = Vger::Resources::Mrf::Report.find(report_params[:id], report_params)
    @report.report_hash = @report.report_data

    #enable for competency reports
    # @assessment = Vger::Resources::Mrf::Assessment.new
    # @assessment.report_data = {:competency_scores => {}, :trait_scores => {}}
    # @report.report_data[:competency_scores].each do |competency, competency_scores|
    #     @assessment.report_data[:competency_scores][competency] = {
    #       :min_score => { :score => 0 },
    #       :max_score => { :score => 0 }
    #     }
    #     competency_scores[:trait_scores].each do |trait_scores|
    #        @assessment.report_data[:trait_scores][trait_scores[:trait][:name]] = {
    #         :min_score => { :score => 0 },
    #         :max_score => { :score => 0 }
    #       } 
    #     end
    # end

     layout = "layouts/mrf/reports.pdf.haml"
    #layout = "layouts/mrf/reports.html.haml"

    # template = "mrf/assessments/reports/competency_report.html.haml"
    # template = "mrf/assessments/reports/competency_report.pdf.haml"
    
    #template = "mrf/assessments/reports/fit_report.html.haml"
     template = "mrf/assessments/reports/fit_report.pdf.haml"
    

    render json:{ 
      content: render_to_string(
        :layout => layout,
        :template => template)
    }
  end

  def s3_report
    report = Vger::Resources::Mrf::Report.find(params[:report_id], params)
    if request.format.to_s == "application/pdf"
      url = S3Utils.get_url(report.pdf_bucket, report.pdf_key)
    else
      url = S3Utils.get_url(report.html_bucket, report.html_key)
    end
    redirect_to url
  end


  protected
  
  def get_norm_buckets
    @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @norm_buckets.empty?
      @norm_buckets = Vger::Resources::Mrf::NormBucket.where(
                      order: "weight ASC", query_options: {
                        company_id: nil
                      }).all
    end
    @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @trait_graph_buckets.empty?
      @trait_graph_buckets = Vger::Resources::Mrf::TraitGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: nil
                      }).all
    end
    @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: @company.id
                      }).all
    
    if @competency_graph_buckets.empty?
      @competency_graph_buckets = Vger::Resources::Mrf::CompetencyGraphBucket.where(
                      order: "min_val ASC", query_options: {
                        company_id: nil
                      }).all
    end
  end

  def get_company
    @company = Vger::Resources::Company.find(params[:company_id], :methods => [])
  end

  def get_assessment
    if params[:id].present?
      @assessment = Vger::Resources::Mrf::Assessment.find(params[:id], company_id: @company.id, :include => {:assessment_traits => { methods: [:trait] } })
    else
      @assessment = Vger::Resources::Mrf::Assessment.new
    end
  end

end
