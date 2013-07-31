class SystemMailer < ActionMailer::Base
  default :from => "sysadmin@jombay.com"
  
  def notify_report_status(context,subject,messages)
    @messages = messages
    mail(:to => "engineering@jombay.com",
         :subject => "[#{Rails.env}] #{subject}")
  end
end
