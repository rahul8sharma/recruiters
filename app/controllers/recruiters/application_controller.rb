class Recruiters::ApplicationController < ApplicationController
  def redirect_if_logged_in!
    if user_signed_in?
      redirect_to recruiters_root_path(:trailing_slash => false)
    end
  end

  def redirect_if_not_logged_in!
    set_auth_token
    if !user_signed_in?
      redirect_to(new_user_session_path(:redirect_to => request.fullpath), :notice => not_logged_in_msg)
    end
  end

  private

  def not_logged_in_msg
    html = "You need to be logged in to continue. New User? "
    html += content_tag(:a, "Register", :href => new_user_registration_path(:redirect_to => request.fullpath))
    html.html_safe
  end

end
