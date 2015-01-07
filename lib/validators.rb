module Validators
  mattr_accessor :login_regex, :bad_login_message,
    :name_regex, :bad_name_message, :phone_regex,
    :email_name_regex, :domain_head_regex, :domain_tld_regex, :email_regex, :bad_email_message

  self.login_regex       = /\A\w[\w\.\-_@]+\z/                     # ASCII, strict
  # self.login_regex       = /\A[[:alnum:]][[:alnum:]\.\-_@]+\z/     # Unicode, strict
  # self.login_regex       = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive

  self.bad_login_message = "use only letters, numbers, and .-_@ please.".freeze

  self.name_regex        = /\A[^[:cntrl:]\\<>\/&]*\z/              # Unicode, permissive
  self.bad_name_message  = "avoid non-printing characters and \\&gt;&lt;&amp;/ please.".freeze

  self.email_name_regex  = '[\w\.%\+\-]+'.freeze
  self.domain_head_regex = '(?:[A-Z0-9\-]+\.)+'.freeze
  self.domain_tld_regex  = '(?:[A-Z]{2}|com|org|net|edu|gov|mil|biz|info|mobi|name|aero|jobs|museum)'.freeze
  self.email_regex       = /\A#{email_name_regex}@#{domain_head_regex}#{domain_tld_regex}\z/i
  self.bad_email_message = "should look like an email address.".freeze

  self.phone_regex = /^[\d\-\(\)\+]{8,16}$/

  def self.clean_mobile_number(mobile_number)
    # Return if the mobile number was blank
    return nil if mobile_number.blank?

    # replace +, -, spaces and leading 0's with blank string
    mobile_number = mobile_number.to_s.gsub(/\s|\+|-/,"").gsub(/^0*/,"")
    # replace leading 91 if mobile number length is 12
    mobile_number = mobile_number.gsub(/^91/,"") if mobile_number.length == 12
    return mobile_number
  end
end
