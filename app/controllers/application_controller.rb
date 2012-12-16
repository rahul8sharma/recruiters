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
end
