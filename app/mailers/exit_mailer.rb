class ExitMailer < ActionMailer::Base
  default :from => "Jombay <sysadmin@jombay.com>"

  def send_exit_report(report_id,report_hash)
    @report_id = report_id
    @report_hash = report_hash
    subject = "Exit Survey Report ready for #{report_hash[:candidate][:name]} "
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end
  
  def send_exit_group_report(report_id,report_hash)
    @report_id = report_id
    @report_hash = report_hash
    subject = "Exit Survey Group Report #{report_hash[:name]} ready for #{report_hash[:survey_id]} "
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end
end  
