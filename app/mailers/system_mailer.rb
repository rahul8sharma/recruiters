class SystemMailer < ActionMailer::Base
  default :from => "Jombay <sysadmin@jombay.com>"

  def notify_report_status(context,subject,messages)
    @messages = messages
    mail(:to => "engineering@jombay.com",
         :subject => "[#{Rails.env}] #{subject}")
  end

  def payment_failure_notice(order_data)
    @order_data = order_data
    subject = "Subscription Payment for company id #{order_data["companyID"]} failed due to some reason"
    mail(:to => "product@jombay.com", :bcc =>"engineering@jombay.com", :subject => subject)
  end

  def send_report(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:candidate][:name]} has completed the #{report_hash[:assessment][:name]} assessment."
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end

  def send_mrf_report(report_id, report_data)
    @report_id = report_id
    @report_data = report_data
    subject = "360 Degree Report ready for #{report_data[:candidate][:id]} #{report_data[:candidate][:name]} "
    to = report_data[:report_email_recipients].present? ? report_data[:report_email_recipients] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end

  def send_report_to_candidate(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:candidate][:name]}, your psychometric report by Jombay is ready!"
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end

  def send_benchmark_report(report_hash)
    @report_hash = report_hash
    subject = "Benchmark Report for Assessment with ID #{report_hash['assessment_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end

  def send_training_requirements_report(report_hash)
    @report_hash = report_hash
    subject = "Training Requirements Report for Assessment with ID #{report_hash['assessment_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end

  def send_training_requirement_group_report(report_hash)
    @report_hash = report_hash
    subject = "Training Requirements Report for Training Requirement Group with ID #{report_hash['training_requirement_group_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : "engineering@jombay.com"
    mail(:to => to, :bcc => "engineering@jombay.com", :subject => subject)
  end
end
