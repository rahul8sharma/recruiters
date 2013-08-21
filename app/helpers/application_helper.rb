module ApplicationHelper
	# renders set of hidden fields and button to add new record using nested_attributes
  def link_to_add_fields(name, append_to_selector,f, parent_klass, association_klass, association, callback, options={})
    new_object = association_klass.new
    obj = nil
    fields = f.fields_for("#{association}_attributes", new_object, :index => "new_#{association}") do |builder|
      obj = builder.object
      render("#{parent_klass.to_s.underscore.pluralize}/"+association.to_s.singularize + "_fields", :f => builder, :options => options)
    end
    link_to_function(name, raw("#{callback}(\"#{append_to_selector}\", \"#{association}\", \"#{escape_javascript(fields)}\")"), :class => "add_fields", :content => "#{fields}", :object_id => "#{obj.id}", :style => options[:style])
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
  
  def sort_link(label,url,order_by)
    order_type = ((params[:order_by].to_s == order_by.to_s && params[:order_type] == "ASC") ? "DESC" : "ASC")
    order_type_text = order_type == "ASC" ? "&uarr;" : "&darr;"
    title = order_type == "ASC" ? "Sort by #{order_by.to_s} in ascending order" : "Sort by #{order_by.to_s} in descending order"
    link_to "#{label} #{order_type_text}".html_safe, "#{url}?order_by=#{order_by}&order_type=#{order_type}", :title => title
  end
end
