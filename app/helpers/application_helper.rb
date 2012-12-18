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

    # Rails.cache.fetch({:top_list => 29_11_2012, :list => list_name, :options => options}, :expires_in => 1.day) do
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
    # end
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
end
