module ReportsHelper
  def get_scale assessment_factor_norms, factor_score
    position = factor_score.norm_bucket.weight - 1
    to_norm_bucket = assessment_factor_norms[factor_score.factor_id].to_norm_bucket
    from_norm_bucket = assessment_factor_norms[factor_score.factor_id].from_norm_bucket  
    width = to_norm_bucket.weight - from_norm_bucket.weight
    offset = from_norm_bucket.weight - 1
    { :position => position, :width => width, :offset => offset }
  end
end
