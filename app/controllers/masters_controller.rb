require 'digest/md5'
class MastersController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  # form for new master password for project vault
  def new
    @master_password = MasterPassword.new
  end

  # create new master password for project vault
  def create
    passwords = params[:master_password]
    if passwords[:password] == passwords[:password_repeat]
      digest = Digest::MD5.hexdigest(master_params[:password])
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
      Rails.cache.write(:master, password, expires_in: 1.minute)
      redirect_to project_vaults_path
    else
      flash[:error] = 'Wrong master password!'
      redirect_to '/projects/' + @project.identifier + '/decrypt'
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
