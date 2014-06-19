class StagingMailInterceptor
  def self.delivering_email(message)
    dont_intercept_mails_from = [
                                 "Jombay <sysadmin@jombay.com>",
                                 "Jombay <errors@jombay.com>"
                                ]
    unless dont_intercept_mails_from.include?(message.from.first)
      #Intercept
      message.subject = "#{message.subject} [TO:#{message.to} CC:#{message.cc} BCC#{message.bcc}]"
      message.to = "test.user@jombay.com"
      message.cc = ""
      message.bcc = ""
    end
  end
end
