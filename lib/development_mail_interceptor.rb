class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.subject} [TO:#{message.to} CC:#{message.cc} BCC#{message.bcc}]"
    message.to = "test.user@jombay.com"
    message.cc = ""
    message.bcc = ""
  end
end
