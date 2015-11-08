require 'digest/md5'
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
      master = Rails.cache.read(:master)
      if master.nil?
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
    @vault = Vault.new(vault_params)
    @vault.project = @project
    @vault.user = User.current
    @vault.private = false
    if @vault.save
      flash[:notice] = 'Password successfully added to vault.'
      redirect_to project_vaults_path
    end
  end

  def update

  end

  def edit

  end

  def destroy

  end

  def vault_params
    params.require(:vault).permit(:host, :login, :password, :notes)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
