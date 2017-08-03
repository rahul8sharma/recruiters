module ReportsHelper
  def get_scale assessment_factor_norms, factor_score
    position = factor_score.norm_bucket.weight - 1
    to_norm_bucket = assessment_factor_norms[factor_score.factor_id].to_norm_bucket
    from_norm_bucket = assessment_factor_norms[factor_score.factor_id].from_norm_bucket  
    width = to_norm_bucket.weight - from_norm_bucket.weight
    offset = from_norm_bucket.weight - 1
    { :position => position, :width => width, :offset => offset }
  end
  
  def convertToRange(old_min, old_max, new_min, new_max, value)
    old_range = old_max - old_min
    new_range = new_max - new_min
    points = (((value - old_min) * new_range).to_f/old_range) + new_min
    points = points.round(2)
    points
  end
  
  def get_competency_scores_page(available,traits_competency)
    Hash[traits_competency.collect do |competency, traits| 
      if available == 0
        pick = []
        available = available - pick.size; 
      else
        pick = traits.size > available ? traits[0..(available-1)] : traits;
        available = available - pick.size; 
        traits_competency[competency] = (traits - traits[0..(pick.size-1)]); 
      end
      [competency,{ pick: pick, pending: (traits.size - pick.size) }]
    end]
  end

  def get_scale_calculations(marker_width, factor_score, company_norm_buckets, gutter)
    scale_width = (company_norm_buckets.size-1)*marker_width
    scale = factor_score[:scale]
    norm_bucket_uid = factor_score[:norm_bucket_uid] 
    from_norm_bucket = company_norm_buckets.detect{|company_norm_bucket| company_norm_bucket.norm_bucket_ids.include? scale[:from_norm_bucket_uid] }
    to_norm_bucket = company_norm_buckets.detect{|company_norm_bucket| company_norm_bucket.norm_bucket_ids.include? scale[:to_norm_bucket_uid] }
    company_norm_bucket = company_norm_buckets.detect{|company_norm_bucket| company_norm_bucket.norm_bucket_ids.include?(norm_bucket_uid)}
    
    offset = marker_width * (from_norm_bucket.weight-1)        
    width = (to_norm_bucket.weight - from_norm_bucket.weight) * marker_width
    width = gutter if width == 0
    #position = (company_norm_bucket.weight - 1) * marker_width
    position = (100 / company_norm_buckets.size) * (company_norm_bucket.weight - 1) 
    position = scale_width-20 if position > scale_width
    scored_weight = company_norm_bucket.weight
    klass = (scored_weight >= from_norm_bucket.weight) ? "favorable" : "less_favorable underlined"
    genericKlass = (scored_weight >= from_norm_bucket.weight && scored_weight <= to_norm_bucket.weight) ? "favorable" : "less_favorable underlined" 

    HashWithIndifferentAccess.new({ 
      offset: offset,
      width: width,
      position: position,
      klass: klass,
      scale_width: scale_width,
      to_norm_bucket_name: to_norm_bucket.name,
      company_norm_bucket_name: company_norm_bucket.name,
      genericKlass: genericKlass
    })
  end

  def get_factors_under_competencies(report)
    all_factor_scores = []
    report.report_hash[:competency_scores].each do |competency, competency_data|
      competency_data[:factor_scores].each do |name, factor_score|  
        new_factor_scores = factor_score.dup
        new_factor_scores[:factor_name] = name
        new_factor_scores[:competency_name] = competency
        new_factor_scores[:competency_data] = competency_data
        all_factor_scores.push new_factor_scores
      end
    end
    all_factor_scores
  end

  def centralAlignTraitNames(factor_name, view_mode)
    if view_mode == "html"
      top =  0
      upperLimit = 30
      multiplier = 15
    else
      top = 5
      upperLimit = 25
      multiplier = 10
    end
    new_factor_name = factor_name.dup
    if new_factor_name.size >= 15 && new_factor_name.split(" ").size == 1
      new_factor_name = [new_factor_name.slice(0,11)+"-",new_factor_name.slice(11,100)].join(' ')
    end  
    new_factor_size = new_factor_name.split(" ").size
    if new_factor_size >= 3
      margin = top
    elsif new_factor_size == 2
      margin = 15
    else
      margin = 20   
    end
  end

end
