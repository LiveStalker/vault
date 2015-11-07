require 'digest/md5'
class MastersController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def new
    @master_password = MasterPassword.new
  end

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

  def decrypt
    @master_password = MasterPassword.new
  end

  def decrypt_post
    password = master_params[:password]
    Rails.cache.write(:master, password, expires_in: 1.minute)
    digest = Digest::MD5.hexdigest(password)
    master_digest = MasterPassword.find_by(:project_id => @project)
    redirect_to project_vaults_path
  end

  def master_params
    params.require(:master_password).permit(:password)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
