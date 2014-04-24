module Crypto
  class AES
    require 'openssl'
    require 'digest/md5'

    def self.decrypt encrypted_string, key
      secret_key = hextobin(Digest::MD5.hexdigest(key))
      init_vector = [
        0x00, 0x01, 0x02, 0x03, 0x04,
        0x05, 0x06, 0x07, 0x08, 0x09,
        0x0a, 0x0b, 0x0c, 0x0d, 0x0e,
        0x0f
      ].pack('C*');

      encrypted_string = hextobin(encrypted_string)

      cipher = OpenSSL::Cipher::Cipher.new('AES-128-CBC')
      cipher.decrypt
      cipher.padding = 1
      cipher.key = secret_key
      cipher.iv = init_vector

      decrypted_text = cipher.update(encrypted_string) + cipher.final

      decrypted_text
    end

    def self.hextobin str
      length = str.length
      binary_string = ""
      count = 0

      while(count < length) do
        substring = str[count, 2]
        packed_string = [substring].pack('H*')

        if(count == 0)
          binary_string = packed_string
        else
          binary_string += packed_string
        end

        count += 2
      end

      return binary_string
    end
  end
end
