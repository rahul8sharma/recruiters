class DevelopmentMailInterceptor
  def self.delivering_email(message)
    fields = [:to, :cc, :bcc]
    recipients =  fields.zip(fields.map{ |field| message.send(field) }).map { |name, value|
      next if value.blank?
      "#{name.capitalize} : #{value}"
    }.compact.join(", ")
    
    message.subject += " => #{recipients}"
    message.to = "test.user@jombay.com"
    message.cc = ""
    message.bcc = ""
  end
end
