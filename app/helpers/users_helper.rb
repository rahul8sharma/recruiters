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
  
  def get_link_for_jit_user(user)
    return user_path(user.id)
  end
  
  def get_link_for_sq_user(user)
    return user_path(user.id)
  end
  
  def get_link_for_jq_user(user)
    return user_path(user.id)
  end
  
  def get_link_for_idp_coach(user)
    return user_path(user.id)
  end
  
  def get_link_for_idp_mentor(user)
    return user_path(user.id)
  end
  
  def get_link_for_idp_candidate(user)
    return user_path(user.id)
  end

  def get_link_for_user(user)
    role = get_role(user)
    if role
      self.respond_to?("get_link_for_#{role.underscore}") ? self.send("get_link_for_#{role.underscore}",user) : "#"
    else
      return "#"
    end
  end
    
  def get_role(user)
    @role ||= user.role_names.select do |role|
      [
        Vger::Resources::Role::RoleName::SUPER_ADMIN,
        Vger::Resources::Role::RoleName::JIT,
        Vger::Resources::Role::RoleName::COMPANY_MANAGER,
        Vger::Resources::Role::RoleName::ADMIN
      ].include?(role)
    end.first
  end
end
