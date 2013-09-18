JombayNotify.configure_database(YAML::load(File.open("#{Rails.root.to_s}/config/jombay-notify.yml"))[Rails.env.to_s]["database"])
JombayNotify.configure_sms_api(YAML::load(File.open("#{Rails.root.to_s}/config/jombay-notify.yml"))[Rails.env.to_s]["sms"]) 
JombayNotify.configure_email_api(YAML::load(File.open("#{Rails.root.to_s}/config/jombay-notify.yml"))[Rails.env.to_s]["email"])  
