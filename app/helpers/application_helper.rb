module ApplicationHelper
	# renders set of hidden fields and button to add new record using nested_attributes
  def link_to_add_fields(name, append_to_selector,f, parent_klass, association_klass, association, callback, options={})
    new_object = association_klass.constantize.new
    obj = nil
    fields = f.fields_for("#{association}", new_object, :index => "new_#{association}") do |builder|
      obj = builder.object
      render("#{parent_klass.to_s.gsub('Vger::Resources','').underscore.pluralize}/"+association.to_s.singularize + "_fields", :f => builder, :options => options)
    end
    link_to_function(name, raw("#{callback}(\"#{append_to_selector}\", \"#{association}\", \"#{escape_javascript(fields)}\")"), :class => "add_fields #{options[:class]}", :content => "#{fields}", :object_id => "#{obj.id}", :style => options[:style])
  end
  
  # renders a form
  def link_to_add_form(partial_path, local_variables)
  	
  end
  
  # this is a UI helper for rendering labels
  # this method could be used to render factual information
  # this method checks if object to be displayed exists 
  # if yes, render the object
  # else render default alternative text / replacement text if present
  # TODO add support for prefix and suffix to the displayed text
  # this could be achieved via options later
  def h(obj, replacement=nil,options={})
    if obj.present?
      return "#{options[:prefix]}#{obj}#{options[:suffix]}"
    else
      replacement ? replacement : "Not available"
    end
  end
  
  # helper for rendering time
  # checks arguments and renders time in "hours:minutes" format
  def htime datetime,replacement=nil,options={}
    if datetime.present?
      if datetime.is_a? String
        DateTime.parse(datetime).strftime("%H:%M")
      elsif datetime.is_a? DateTime
        return datetime.strftime("%H:%M")
      end
    else
      replacement ? replacement : "Not available"
    end
  end
  
  # helper for rendering date
  # checks arguments and renders data in "date/month/year" format
  def hdate date,replacement=nil,options={}
    if date.present?
      if date.is_a? String
        Date.parse(date).strftime("%d/%m/%Y")
      elsif date.is_a? Date
        return date.strftime("%d/%m/%Y")
      end
    else
      replacement ? replacement : "Not available"
    end
  end
  
  
  # helper for rendering a sort link
  # this helper returns a link tag with an up/down css background image
  def sort_link(label,url,order_by,search_options={})
    search_options ||= {}
    order_type = ((params[:order_by].to_s == order_by.to_s && params[:order_type] == "ASC") ? "DESC" : "ASC")
    order_type_class = order_type == "ASC" ? "down" : "up"
    order_type_class = "#{order_type_class} active" if(params[:order_by].to_s == order_by.to_s)    
    title = order_type == "ASC" ? "Sort by #{order_by.to_s} in ascending order" : "Sort by #{order_by.to_s} in descending order"
    final_url = "#{url}?order_by=#{order_by}&order_type=#{order_type}"
    search_options.each do |key,value|
      final_url = "#{final_url}&search[#{key}]=#{value}"
    end    
    link_to "#{label} <i class= 'icon-chevron-#{order_type_class} small-text line-height1'></i>".html_safe, final_url, :title => title, :class => order_type_class
  end
  
  def test_statuses
    {
      "" => "All",
      "sent" => "Pending",
      "started" => "Started",
      "completed" => "Completed",
      "ready_for_scoring" => "Completed",
      "scored" => "Completed",
      "expired" => "Expired"
    }
  end
  
  def test_status_options
    {
      "" => "All",
      "sent" => "Pending",
      "started" => "Started",
      "scored" => "Completed",
      "expired" => "Expired"
    }
  end
  
  def report_statuses
    {
      "uploaded" => "Completed",
      "scored" => "Generating Report...",
      "failed" => "Failed to generate report"
    }
  end
  
  def exit_report_statuses
    {
      "uploaded" => "Completed",
      "scored" => "Completed",
      "failed" => "Failed to generate report"
    }
  end
end
