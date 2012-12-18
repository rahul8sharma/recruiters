module ApplicationHelper
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
