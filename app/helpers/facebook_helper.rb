module FacebookHelper

  # NOT USED
  def fb_login_and_redirect(url, options = {})
    js = update_page do |page|
      page.redirect_to url
    end

    text = options.delete(:text)

    #rails 3 only escapes non-html_safe strings, so get the raw string instead of the SafeBuffer
    content_tag("fb:login-button",text,options.merge(:onlogin=>js.to_str))
  end
  
  def fb_like_button(options = {})
    # http://developers.facebook.com/docs/reference/plugins/like/
    defaults = {
      :layout => "button_count",
      :show_faces => "true",
      :font => "lucida grande"
    }
    content_tag("fb:like", "", defaults.merge(options))
  end
  # END NOT USED

  # Helper to return umbra fb login link
  def facebook_connect_link(options={}, callback_url_options={})
    options.reverse_merge!({
        :text => "Connect using",
        :redirect_to => root_path
      })

    if current_user
      url_options = {
        fb: true,
        auth_token: session["umbra_user"],
        redirect_to: wrapper_callback_users_url({wrapper_redirect: options[:redirect_to]}.reverse_merge(callback_url_options))
      }
    else
      url_options = {
        fb: true,
        invitation_token: options[:invitation_token],
        redirect_to: wrapper_callback_users_url({wrapper_redirect: options[:redirect_to]}.reverse_merge(callback_url_options))
      }
    end

    url = [[Vger::Authentication.url, "users", "auth", "facebook"] * "/", url_options.to_param] * "?"

    content_tag(:a, {:href => url, :class => "facebook-signin-button", :title => "#{ options[:text] } Facebook"}.merge(options[:link_options]), false) do
      content_tag(:span, "", {:class => "fb_icon"}, false) + content_tag(:div, {:class => "fb_text"}, false) do
        (options[:text] + " " + content_tag(:strong, "Facebook", false)).html_safe
      end
    end
  end

  # NOT USED  
  def facebooker_login_link(options={}, *args)
    defaults = {
      :size => :xlarge,
      :length => :long,
      :text => 'Login with Facebook',
      :version => "3",
      :scope => Rails.application.config.fb_scope.join(",")
    }
    defaults = defaults.merge(options)

    params = []
    params << add_campaign_source
    params << 'fb=true'
    params += args

    redirect_to = wrapper_callback_users_url(:wrapper_redirect => (!!@redirect_to ? @redirect_to : nil),
                                             :job => @jobid)
    #redirect_to_b64 = Base64.encode64(redirect_to).gsub("\n", '')


    params << "redirect_to=" + redirect_to
    params = params.join("&")

    url = Vger::Authentication.url + "/users/auth/facebook" + params
    #    url =  fb_callback_users_path + params #user_omniauth_authorize_url(:provider => 'facebook', :host => "localhost:8000") + params
    fb_login_and_redirect(url, defaults)
  end

  def non_fbml_fb_profile_pic(auth, options)
    image_url = "http://graph.facebook.com/#{ auth.uid }/picture?#{ options.to_query }"
    tag(:img, :src => image_url)
  end

  def fb_profile_pic(user, options)
    # valid options:
    # uid, size, linked, facebook-logo, width, height
    # documentation here: http://developers.facebook.com/docs/reference/fbml/profile-pic/
    options = options.merge ({ :uid => user.external_auth(:facebook).uid })
    tag("fb:profile-pic", options)
  end
  # END NOT USED

end
