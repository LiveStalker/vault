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

  def write_master_cache(id, value, prj)
    # refresh cache
    expires_in = Setting.plugin_password_vault['VAULT_IDLE']
    m = expires_in.to_i
    Rails.cache.write(:"master#{id}#{prj}", value, expires_in: m.minute)
  end

  def read_master_cache(id, prj)
    Rails.cache.read(:"master#{id}#{prj}")
  end

  def del_master_cache(id, prj)
    Rails.cache.delete(:"master#{id}#{prj}")
  end

  def reset_master_cache(prj)
    users = User.status('1').all
    users.each do |u|
      Rails.cache.delete(:"master#{u.id}#{prj}")
    end
  end

  def item_output(type, value, notes)
    if type == 'RDP'
      url = '<a href="rdp://' + value + '">rdp://' + value + '</a>'
      return url.html_safe
    elsif type == 'HTTP'
      url = '<a href="http://' + value +'">' + value +'</a>'
      return url.html_safe
    elsif type == 'HTTPS'
      url = '<a href="https://' + value +'">' + value +'</a>'
      return url.html_safe
    else
      return value
    end
  end
end
