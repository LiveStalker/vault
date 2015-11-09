require 'digest/sha2'
require 'openssl'
require 'base64'

module VaultsHelper
  def vault_decrypt(value, cipher_key)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = Digest::SHA2.digest cipher_key
    cipher.update(Base64.decode64(value.to_s)) + cipher.final
  end
end
