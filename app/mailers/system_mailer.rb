class SystemMailer < ActionMailer::Base
  default :from => "sysadmin@jombay.com"
  
  def report_exception(exception,context)
    @exception = exception
    mail(:to => "engineering@jombay.com",
         :subject => "Exception in '#{context}'")
  end
end
