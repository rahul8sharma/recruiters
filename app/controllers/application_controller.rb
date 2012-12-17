require 'vger/helpers/recruiters_yoren_helper'

class ApplicationController < ActionController::Base
  protect_from_forgery

  include RecruitersYorenHelper
  
  before_filter :set_auth_token
  around_filter :define_request_in_active_record

  def default_after_signup_url
    recruiters_root_url(:trailing_slash => false)
  end

  def default_after_signup_path
    recruiters_root_path(:trailing_slash => false)
  end

  def redirect_if_logged_in!
    if user_signed_in?
      redirect_to recruiters_root_path(:trailing_slash => false)
    end
  end

  def controller_redirect_path
    recruiters_root_path
  end
  
  def redirect_if_not_logged_in!
    set_auth_token

    if !user_signed_in?
      redirect_to((controller_redirect_path || root_path(:trailing_slash => false)), :notice => "You need to be signed in to continue!")
    end
  end
end
