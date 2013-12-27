class SystemMailer < ActionMailer::Base
  default :from => "Jombay <sysadmin@jombay.com>"
  
  def notify_report_status(context,subject,messages)
    @messages = messages
    mail(:to => "engineering@jombay.com",
         :subject => "[#{Rails.env}] #{subject}")
  end
  
  def send_report(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:candidate][:name]} has completed the #{report_hash[:assessment][:name]} assessment."
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end
  
  def send_benchmark_report(report_hash)
    @report_hash = report_hash
    subject = "Benchmark Report for Assessment with ID #{report_hash['assessment_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end
end
