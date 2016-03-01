module UsersHelper
  def activation_hosts
    hosts_html = ''
    Rails.application.config.domain.each_pair do | key, value |
      hosts_html += "<option value='#{value.gsub("http://", '')}'>#{key.gsub("_url", '').gsub("_", " ").capitalize}</option>"
    end

    hosts_html
  end
  
  def get_link_for_admin(user)
    user_settings_company_path(user.company_id) if user.company_id.present?
  end
  
  def get_link_for_candidate(user)
    user_path(user.id)
  end
  
  def get_link_for_company_manager(user)
    company_managers_company_path(user.company_ids.first) if user.company_ids.present?
  end
  
  def get_link_for_super_admin(user)
    return user_path(user.id)
  end
  
  def get_link_for_jit(user)
    return user_path(user.id)
  end
  
  def get_link_for_sq(user)
    return user_path(user.id)
  end
  
  def get_link_for_jq(user)
    return user_path(user.id)
  end
end
