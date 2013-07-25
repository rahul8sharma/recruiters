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
  
  
  def h(obj,options={})
    if obj.present?
      return obj
    else
      "Not available"
    end
  end
  
  def hdate
    
  end
end
