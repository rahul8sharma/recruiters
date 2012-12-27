module ApplicationHelper
  # Collection to use for top list
  def collection_for_top_list(list_name)
    case list_name
    when :fields
      Vger::Spartan::Opus::Recommendation.fields
    when :job_categories
      Vger::Spartan::Opus::JobCategory.find(:all)
    when :india_cities
      Vger::Penumbra::Geography.find(
                                :all,
                                :params => {
                                       :query_options => {
                                         :geotype => Vger::Penumbra::Geography.geotype(:city),
                                         :country_id => Vger::Penumbra::Geography.find(
                                                                                  :first,
                                                                                  :params => {
                                                                                         :query_options => {
                                                                                           :name => "India",
                                                                                           :geotype => Vger::Penumbra::Geography.geotype(:country)
                                                                                         }
                                                                                       }
                                                                                  ).id
                                       }
                                     }
                                )
    end
  end


  # Creates options for top list with top items from yml
  def top_list_for_select(list_name, options = {})
    options.reverse_merge!({
        :key_attribute => :name,
        :display_method => :name,
        :value_method => :id,
        :top_label => "Top",
        :other_label => "Other"
      })

    Rails.cache.fetch({:top_list => 18_12_2012, :list => list_name, :options => options}, :expires_in => 1.day) do
      top_elements = Rails.application.config.top_lists[list_name]
      collection = collection_for_top_list(list_name)
      grouped_options_for_select([
                                   [
                                     options[:top_label],
                                     collection.select{|element| top_elements.include? element.send(options[:key_attribute]) }.collect{|element| [element.send(options[:display_method]), element.send(options[:value_method])] }
                                   ],
                                   [
                                     options[:other_label],
                                     collection.reject{|element| top_elements.include? element.send(options[:key_attribute]) }.collect{|element| [element.send(options[:display_method]), element.send(options[:value_method])] }
                                   ]
                                 ])
    end
  end

  # Helper wrapper for will_paginate to add default options to work with
  # bootstrap
  def bootstrap_paginate(pages, options={})
    options.reverse_merge!(
      :class => 'pagination margin', 
      :renderer => BootstrapLinkRenderer, 
      :previous_label => '&larr;'.html_safe, 
      :next_label => '&rarr;'.html_safe
    )
    will_paginate(pages, options)
  end

  def bootstrap_type(type)
    case type
    when :alert
      "alert-warning"
    when :error
      "alert-error"
    when :notice
      "alert-success"
    else
      "alert-#{ type.to_s }"
    end
  end

  def timeago(datetime, element = :div, options = {})
    content_tag(element, datetime.strftime('%d-%m-%Y %H:%M'), options.merge(:title => datetime.getutc.iso8601, "data-dynamicTime" => true)) if datetime
  end

  def render_umbra_user_display_image(leo_user, options={})
    umbra_user = Vger::Penumbra::User.find_by_sid(leo_user.sid)
      
      # Display the FB profile pic only if the user is an FB user and hasn't
    # yet uploaded a profile picture

    if umbra_user.profile_photo_small.include?("default_user_icon") && umbra_user.external_user?(:facebook)
      non_fbml_fb_profile_pic(umbra_user.external_auth(:facebook), {
                                :type => :square
                              }.merge(options))
    else
      image_tag("default_user_icon.png")
    end
  end

  def rating_stars(rating, options={})
    options.merge!(
      "data-rating" => rating
      )
    content_tag(:div, "", options)
  end
end
