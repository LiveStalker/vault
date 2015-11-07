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
      end
    end
  end


  def new
    @vault = Vault.new()
  end

  def create

  end

  def update

  end

  def edit

  end

  def destroy

  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
