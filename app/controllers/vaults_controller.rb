require 'digest/md5'
require 'digest/sha2'
require 'openssl'
require 'base64'

class VaultsController < ApplicationController
  unloadable
  include VaultsHelper
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
      #@master = Rails.cache.read(:master)
      @master = read_master_cache(User.current.id)
      if @master.nil?
        # no master in cache
        redirect_to '/projects/' + @project.identifier + '/decrypt'
      else
        @vault_passwords = Vault.where(:project => @project).all
      end
    end
  end

  def new
    #@master = Rails.cache.read(:master)
    @master = read_master_cache(User.current.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.new()
    end
  end

  def create
    @master = params[:vault][:master]
    form_params = vault_params
    # encrypt login and password
    form_params[:login] = vault_encrypt(form_params[:login], @master)
    form_params[:password] = vault_encrypt(form_params[:password], @master)
    @vault = Vault.new(form_params)
    @vault.project = @project
    @vault.user = User.current
    @vault.private = false
    # refresh cache
    #expires_in = Setting.plugin_password_vault['VAULT_IDLE']
    #m = expires_in.to_i
    #Rails.cache.write(:master, @master, expires_in: m.minute)
    write_master_cache(User.current.id, @master)
    if @vault.save
      # save successfully
      flash[:notice] = 'Password successfully added to vault.'
      redirect_to project_vaults_path
    else
      # validation fail
      @vault.login = vault_decrypt(@vault.login, @master)
      @vault.password = vault_decrypt(@vault.password, @master)
      render :new
    end
  end

  def update
    @vault = Vault.find(params[:id])
    @master = params[:vault][:master]
    form_params = vault_params
    form_params[:login] = vault_encrypt(form_params[:login], @master)
    form_params[:password] = vault_encrypt(form_params[:password], @master)
    @vault.assign_attributes(form_params)
    # refresh cache
    #expires_in = Setting.plugin_password_vault['VAULT_IDLE']
    #m = expires_in.to_i
    #Rails.cache.write(:master, @master, expires_in: m.minute)
    write_master_cache(User.current.id, @master)
    if @vault.valid? and (request.patch? and @vault.save)
      # save successfully
      flash[:notice] = 'Password successfully added to vault.'
      flash[:notice] = 'Password successfully updated.'
      redirect_to project_vaults_path
    else
      # validation fail
      @vault.login = vault_decrypt(@vault.login, @master)
      @vault.password = vault_decrypt(@vault.password, @master)
      render :edit
    end
  end

  def edit
    #@master = Rails.cache.read(:master)
    @master = read_master_cache(User.current.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.find(params[:id])
      @vault.login = vault_decrypt(@vault.login, @master)
      @vault.password = vault_decrypt(@vault.password, @master)
    end
  end

  def destroy
    #@master = Rails.cache.read(:master)
    @master = read_master_cache(User.current.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.find(params[:id])
      @vault.delete
      # refresh cache
      #expires_in = Setting.plugin_password_vault['VAULT_IDLE']
      #m = expires_in.to_i
      #Rails.cache.write(:master, @master, expires_in: m.minute)
      write_master_cache(User.current.id, @master)
      redirect_to project_vaults_path
    end
  end

  def vault_params
    params.require(:vault).permit(:host, :login, :password, :notes)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

end
