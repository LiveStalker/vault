require 'digest/md5'
require 'digest/sha2'
require 'openssl'
require 'base64'

class VaultsController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def index
    #check that master password exist
    @master_password = MasterPassword.find_by(:project_id => @project)
    if @master_password.nil?
      # master password dose not exist
      if User.current.admin?
        flash[:notice] = 'Create new master password for encrypting vault!'
        redirect_to new_project_master_path
      else
        flash[:error] = 'Master password not found!'
        flash[:notice] = 'Ask the administrator to set a master password!'
      end
    else
      # master password exist
      @master = Rails.cache.read(:master)
      if @master.nil?
        # no master in cache
        redirect_to '/projects/' + @project.identifier + '/decrypt'
      else
        @vault_passwords = Vault.where(:project => @project).all
      end
    end
  end

  def new
    @master = Rails.cache.read(:master)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.new()
    end
  end

  def create
    master = params[:vault][:master]
    obj_params = vault_params
    obj_params[:login] = vault_encrypt(obj_params[:login], master)
    obj_params[:password] = vault_encrypt(obj_params[:password], master)
    @vault = Vault.new(obj_params)
    @vault.project = @project
    @vault.user = User.current
    @vault.private = false
    if @vault.save
      # refresh cache
      Rails.cache.write(master, vault_params[:password], expires_in: 1.minute)
      flash[:notice] = 'Password successfully added to vault.'
      redirect_to project_vaults_path
    end
  end

  def update
    @vault = Vault.find(params[:id])
    @vault.update_attributes(vault_params)
    if request.patch? and @vault.save
      # refresh cache
      Rails.cache.write(params[:vault][:master], vault_params[:password], expires_in: 1.minute)
      flash[:notice] = 'Password successfully added to vault.'
      flash[:notice] = 'Password successfully updated.'
      redirect_to project_vaults_path
    else
      render :action => 'edit', :id => @vault.id
    end
  end

  def edit
    @master = Rails.cache.read(:master)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.find(params[:id])
    end
  end

  def destroy

  end

  def vault_params
    params.require(:vault).permit(:host, :login, :password, :notes)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

  def vault_decrypt(value, cipher_key)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = Digest::SHA2.digest cipher_key
    cipher.update(Base64.decode64(value.to_s)) + cipher.final
  end

  def vault_encrypt(value, cipher_key)
    cipher = OpenSSL::Cipher.new('aes-256-cbc')
    cipher.encrypt
    cipher.key = Digest::SHA2.digest cipher_key
    Base64.encode64(cipher.update(value.to_s) + cipher.final)
  end
end
