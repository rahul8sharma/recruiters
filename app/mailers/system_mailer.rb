class SystemMailer < ActionMailer::Base
  default :from => "Jombay <sysadmin@jombay.com>"

  def notify_report_status(context,subject,messages)
    @messages = messages
    to_email = [
      Rails.application.config.emails[:jit_recipients][:engineering],
      Rails.application.config.emails[:jit_recipients][:product],
      Rails.application.config.emails[:jit_recipients][:operations]
    ]
    mail(
      :to => to_email.join(","),
      :subject => "[#{Rails.env}] #{subject}"
    )
  end

  def payment_failure_notice(order_data)
    @order_data = order_data
    subject = "Subscription Payment for company id #{order_data["companyID"]} failed due to some reason"
    mail(
      :to => "product@jombay.com", 
      :bcc =>Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_report(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:user][:name]} has completed the #{report_hash[:assessment][:name]} assessment."
    recipients = report_hash[:report_email_recipients].to_s.split(",")
    recipients.delete report_hash[:user][:email]
    to = recipients.present? ? recipients.join(",") : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end
  
  def send_jq_report(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:user][:name]} has completed the #{report_hash[:assessment][:name]} assessment."
    recipients = report_hash[:report_email_recipients].to_s.split(",")
    recipients.delete report_hash[:user][:email]
    to = recipients.present? ? recipients.join(",") : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_mrf_report(report_id, report_hash)
    @report_id = report_id
    @report_hash = report_hash
    subject = "360 Degree Report ready for #{report_hash[:user][:id]} #{report_hash[:user][:name]} "
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end
  
  def send_mrf_group_report(report_id, report_hash)
    @report_id = report_id
    @report_hash = report_hash
    subject = "360 Degree Group Report ready for #{report_hash[:assessment][:id]}"
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_engagement_report(report_id,report_hash)
    @report_id = report_id
    @report_hash = report_hash
    subject = "Engagement Survery Report ready for #{report_hash[:user][:name]} "
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end
  
  def send_report_to_user(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:user][:name]}, your psychometric report by Jombay is ready!"
    to = report_hash[:user][:email].present? ? report_hash[:user][:email] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_report_to_manager(report_hash)
    @report_hash = report_hash
    subject = "#{report_hash[:user][:name]} has completed the #{report_hash[:assessment][:name]} assessment."
    to = report_hash[:report_receiver][:email]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_benchmark_report(report_hash)
    @report_hash = report_hash
    subject = "Benchmark Report for Assessment with ID #{report_hash['assessment_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_training_requirements_report(report_hash)
    @report_hash = report_hash
    subject = "Training Requirements Report for Assessment with ID #{report_hash['assessment_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_training_requirement_group_report(report_hash)
    @report_hash = report_hash
    subject = "Training Requirements Report for Training Requirement Group with ID #{report_hash['training_requirement_group_id']} is generated."
    to = report_hash['report_email_recipients'].present? ? report_hash['report_email_recipients'] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end

  def send_oac_report(report_id, report_hash)
    @report_id = report_id
    @report_hash = report_hash
    subject = "OAC Report ready for #{report_hash[:user][:id]} #{report_hash[:user][:name]} "
    to = report_hash[:report_email_recipients].present? ? report_hash[:report_email_recipients] : Rails.application.config.emails[:jit_recipients][:engineering]
    mail(
      :to => to, 
      :bcc => Rails.application.config.emails[:jit_recipients][:engineering], 
      :subject => subject
    )
  end
end
