module ValidationHelper
  VALID_REGEX = /^(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})$/i

  def validateEmail? email    
    if email.present? && email =~ VALID_REGEX
      return true
    else
      return false
    end
  end
end
