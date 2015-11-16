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
      @master = read_master_cache(User.current.id, @project.id)
      if @master.nil?
        # no master in cache
        redirect_to '/projects/' + @project.identifier + '/decrypt'
      else
        @vault_passwords = Vault.where(:project => @project).where(:private => false).all
        @vault_passwords_p = Vault.where(:project => @project).where(:user => User.current).where(:private => true).all
      end
    end
  end

  def new
    @master = read_master_cache(User.current.id, @project.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.new()
    end
  end

  def create
    @master = params[:vault][:master]
    # test cache
    master_from_cache = read_master_cache(User.current.id, @project.id)
    if master_from_cache.nil?
      flash[:error] = 'Session expired.'
      redirect_to ('/projects/' + @project.identifier + '/decrypt') and return
    end
    if master_from_cache != @master
      flash[:error] = 'Somebody change master password. Please enter new master password and try again create/update.'
      redirect_to ('/projects/' + @project.identifier + '/decrypt') and return
    end
    # end test cache
    form_params = vault_params
    # encrypt login and password
    form_params[:login] = vault_encrypt(form_params[:login], @master)
    form_params[:password] = vault_encrypt(form_params[:password], @master)
    @vault = Vault.new(form_params)
    @vault.project = @project
    @vault.user = User.current
    # refresh cache
    write_master_cache(User.current.id, @master, @project.id)
    if @vault.save
      # save successfully
      flash[:notice] = 'Password successfully added to vault.'
      redirect_to(project_vaults_path) and return
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
    # test cache
    master_from_cache = read_master_cache(User.current.id, @project.id)
    if master_from_cache.nil?
      flash[:error] = 'Session expired.'
      redirect_to ('/projects/' + @project.identifier + '/decrypt') and return
    end
    if master_from_cache != @master
      flash[:error] = 'Somebody change master password. Please enter new master password and try again create/update.'
      redirect_to('/projects/' + @project.identifier + '/decrypt') and return
    end
    # end test cache
    form_params = vault_params
    form_params[:login] = vault_encrypt(form_params[:login], @master)
    form_params[:password] = vault_encrypt(form_params[:password], @master)
    @vault.assign_attributes(form_params)
    # refresh cache
    write_master_cache(User.current.id, @master, @project.id)
    if @vault.valid? and (request.patch? and @vault.save)
      # save successfully
      flash[:notice] = 'Password successfully added to vault.'
      flash[:notice] = 'Password successfully updated.'
      redirect_to(project_vaults_path) and return
    else
      # validation fail
      @vault.login = vault_decrypt(@vault.login, @master)
      @vault.password = vault_decrypt(@vault.password, @master)
      render :edit
    end
  end

  def edit
    @master = read_master_cache(User.current.id, @project.id)
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
    @master = read_master_cache(User.current.id, @project.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @vault = Vault.find(params[:id])
      @vault.delete
      # refresh cache
      write_master_cache(User.current.id, @master, @project.id)
      redirect_to project_vaults_path
    end
  end

  def vault_params
    params.require(:vault).permit(:host, :login, :password, :notes, :private)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end

  def close_vault
    del_master_cache(User.current.id, @project.id)
    redirect_to '/projects/' + @project.identifier + '/decrypt'
  end
end
