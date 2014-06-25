class SpecialMasterDataController < MasterDataController 
  def search_columns
    [
      :industry_id,
      :functional_area_id, 
      :job_experience_id,
      :factor_id
    ]
  end
  
  def select_industry_id
    industries = [ ["Global",""] ]
    industries |= Vger::Resources::Industry.all.to_a.collect{|industry| [industry.name, industry.id] }
    Hash[industries]
  end
  
  def select_functional_area_id
    functional_areas = [ ["Global",""] ]
    functional_areas |= Vger::Resources::FunctionalArea.all.to_a.collect{|functional_area| [functional_area.name, functional_area.id] }
    Hash[functional_areas]
  end
  
  def select_job_experience_id
    job_experiences = [ ["Global",""] ]
    job_experiences |= Vger::Resources::JobExperience.all.to_a.collect{|job_exp| [job_exp.display_text, job_exp.id] }
    Hash[job_experiences]
  end
  
  def select_factor_id
    factors = [ ["Global",""] ]
    factors |= Vger::Resources::Suitability::Factor.all.to_a.collect{|factor| [factor.name, factor.id] }
    Hash[factors]
  end
end
