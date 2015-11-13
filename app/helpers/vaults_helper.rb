require 'digest/sha2'
require 'openssl'
require 'base64'

module VaultsHelper
  def vault_decrypt(value, cipher_key)
    if value.to_s != ''
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.decrypt
      cipher.key = Digest::SHA2.digest cipher_key
      cipher.update(Base64.decode64(value.to_s)) + cipher.final
    end
  end

  def vault_encrypt(value, cipher_key)
    if value.to_s != ''
      cipher = OpenSSL::Cipher.new('aes-256-cbc')
      cipher.encrypt
      cipher.key = Digest::SHA2.digest cipher_key
      Base64.encode64(cipher.update(value.to_s) + cipher.final)
    end
  end

  def write_master_cache(id, value)
    # refresh cache
    expires_in = Setting.plugin_password_vault['VAULT_IDLE']
    m = expires_in.to_i
    Rails.cache.write(:"master#{id}", value, expires_in: m.minute)
  end

  def read_master_cache(id)
    Rails.cache.read(:"master#{id}")
  end

  def reset_master_cache
    users = User.status('1').all
    users.each do |u|
      Rails.cache.delete(:"master#{u.id}")
    end
  end
end
