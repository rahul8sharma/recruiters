class StagingMailInterceptor
  def self.delivering_email(message)
    unless (message.from.to_a & ["errors@jombay.com"]) == ["errors@jombay.com"]
      message.subject = "TO:#{message.to} CC:#{message.cc} BCC#{message.bcc} #{message.subject}"
      message.to = "test.user@jombay.com"
      message.cc = ""
      message.bcc = ""
    end
  end
end
