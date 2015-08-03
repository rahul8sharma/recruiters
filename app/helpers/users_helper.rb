module UsersHelper
  def get_link_for_admin(user)
    user_settings_company_path(user.company_ids.first)
  end
  
  def get_link_for_candidate(user)
    company_id = user.company_ids.first
    assessment_id = user.assessment_ids.first
    candidate_company_custom_assessment_path(company_id, assessment_id, :candidate_id => user.id) if company_id && assessment_id
  end
  
  def get_link_for_company_manager(user)
    company_managers_company_path(user.company_ids.first)
  end
  
  def get_link_for_super_admin(user)
    
  end
end
