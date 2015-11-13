require 'digest/md5'
class MastersController < ApplicationController
  unloadable
  include VaultsHelper
  before_filter :find_project, :authorize

  # form for new master password for project vault
  def new
    @master_password = MasterPassword.new
  end

  # create new master password for project vault
  def create
    passwords = params[:master_password]
    logger.info(passwords)
    if passwords[:password] == passwords[:password_repeat]
      digest = Digest::MD5.hexdigest(master_params[:password])
      logger.info(digest)
      @master_password = MasterPassword.new(:password => digest)
      @master_password.project = @project
      @master_password.save()
      flash[:notice] = 'Master password created.'
      redirect_to project_vaults_path
    end
  end

  # form for enter master password for decrypt vault
  def decrypt
    @master_password = MasterPassword.new
  end

  # check master password
  def decrypt_post
    password = master_params[:password]
    digest = Digest::MD5.hexdigest(password)
    master_digest = MasterPassword.find_by(:project_id => @project)
    if digest == master_digest.password
      #expires_in = Setting.plugin_password_vault['VAULT_IDLE'].to_i
      #Rails.cache.write(:master, password, expires_in: expires_in.minute)
      write_master_cache(User.current.id, password)
      redirect_to project_vaults_path
    else
      flash[:error] = 'Wrong master password!'
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    end
  end

  # form for change  master password
  def change_master
    #@master = Rails.cache.read(:master)
    @master = read_master_cache(User.current.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @change_password = MasterPassword.new
    end
  end

  # decrypt/encrypt change master password
  def change_master_post
    passwords = params[:master_password]
    old_password = passwords[:old_password]
    old_password_digest1 = Digest::MD5.hexdigest(old_password)
    old_password_digest2 = MasterPassword.find_by(:project_id => @project)
    if (old_password_digest1 == old_password_digest2.password and passwords[:new_password] == passwords[:password_repeat])
      # decrypt-encrypt all passwords
      @vault_passwords = Vault.where(:project => @project).all
      @vault_passwords.each do |p|
        login = vault_decrypt(p.login, old_password)
        password = vault_decrypt(p.password, old_password)
        login = vault_encrypt(login, passwords[:new_password])
        password = vault_encrypt(password, passwords[:new_password])
        p.update(login: login, password: password)
      end
      # save new password digest
      digest = Digest::MD5.hexdigest(passwords[:new_password])
      old_password_digest2.update(password: digest)
      # refresh cache
      #expires_in = Setting.plugin_password_vault['VAULT_IDLE']
      #m = expires_in.to_i
      #Rails.cache.write(:master, passwords[:new_password], expires_in: m.minute)
      reset_master_cache
      write_master_cache(User.current.id, passwords[:new_password])
      # notice
      flash[:notice] = 'Master password changed. Do not forget announce a new password to your employees.'
      redirect_to project_vaults_path
    else
      flash[:error] = 'Password mismatch.'
      redirect_to project_vaults_path
    end
  end

  # get params for creating new master password
  def master_params
    params.require(:master_password).permit(:password)
  end

  # find project id
  def find_project
    @project = Project.find(params[:project_id])
  end
end
