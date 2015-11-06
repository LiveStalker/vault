class MastersController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def new
    @master_password = MasterPassword.new
  end

  def create
    passwords = params[:master_password]
    if passwords[:password] == passwords[:password_repeat]
      @master_password = MasterPassword.new(master_params)
      @master_password.project = @project
      @master_password.save()
      flash[:notice] = 'Master password created.'
      redirect_to project_vaults_path
    end
  end

  def master_params
    params.require(:master_password).permit(:password)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
