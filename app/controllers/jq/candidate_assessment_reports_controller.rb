class Jq::CandidateAssessmentReportsController < MasterDataController
  def api_resource
    Vger::Resources::Jq::CandidateAssessmentReport
  end
  
  def manage
  end
  
  def export_norm_population
    Vger::Resources::Jq::CandidateAssessmentReport\
      .export_norm_population({:args => params[:args]})
    redirect_to request.env['HTTP_REFERER'], notice: "Export operation queued. Email notification should arrive as soon as the export is complete."
  end
  
  def import_norm_population
    if !params[:file] || !params[:file][:file]
      flash[:notice] = "Please select a zip file."
      redirect_to request.env['HTTP_REFERER'] and return
    end
    data = params[:file][:file].read
    now = Time.now
    s3_key = "jq_norm_population/#{now.strftime('%d_%m_%Y_%H_%I_%p')}"
    obj = S3Utils.upload(s3_key, data)

    Vger::Resources::Jq::CandidateAssessmentReport\
      .import_norm_population(
                      :args => {
                        :bucket => obj.bucket.name,
                        :key => obj.key
                      }.merge(params[:args])
                    )
    redirect_to request.env['HTTP_REFERER'], notice: "Import operation queued. Email notification should arrive as soon as the import is complete."
  end
  
  def index_columns
    [
      :id,
      :candidate_id,
      :assessment_id,
      :functional_area_id,
      :industry_id,
      :job_experience_id
    ]
  end
  
  def search_columns
    [
      :candidate_id,
      :assessment_id,
      :functional_area_id,
      :industry_id,
      :job_experience_id
    ]
  end
end
