module FormBuilder::DefinedFormsHelper
  def render_defined_field(defined_field)
    case defined_field.field_type
      when Vger::Resources::FormBuilder::DefinedField::FieldType::TEXT_FIELD
        return text_field_tag(defined_field.identifier, defined_field.default_value, placeholder: defined_field.placeholder, required: defined_field.is_mandatory)
      when Vger::Resources::FormBuilder::DefinedField::FieldType::TEXT_AREA
        return text_area_tag(defined_field.identifier, defined_field.default_value, placeholder: defined_field.placeholder, required: defined_field.is_mandatory, rows: 5, cols: 20)
      when Vger::Resources::FormBuilder::DefinedField::FieldType::DROP_DOWN
        Rails.logger.ap defined_field.options
        return select_tag(defined_field.identifier, options_for_select(defined_field.options), { prompt: defined_field.placeholder, value: defined_field.default_value, required: defined_field.is_mandatory })
      when Vger::Resources::FormBuilder::DefinedField::FieldType::CHECK_BOX
        return check_box_tag(defined_field.identifier, (defined_field.default_value == 'false' ? 0 : 1), checked: defined_field.default_value == 'true')
      when Vger::Resources::FormBuilder::DefinedField::FieldType::RADIO_BUTTON
        html = ""
        defined_field.options.each do |option|
          html = "#{html}#{radio_button_tag(defined_field.identifier, option, defined_field.default_value == option.to_s, group_name: defined_field.identifier)}"
          html = "#{html}&nbsp;#{label_tag(option,option, for: defined_field.identifier+'_'+option)} &nbsp;&nbsp;"
        end  
        return html.html_safe  
      else
        raise "Invalid Field Type #{defined_field.field_type}"  
    end
  end
end
