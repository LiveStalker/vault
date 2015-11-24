class SitemsController < ApplicationController
  unloadable
  include VaultsHelper
  before_filter :find_project, :authorize

  def new
    @vault_id = params[:vault_id]
    @sitem = Sitem.new
  end

  def create
    @vault_id = params[:vault_id]
    @sitem = Sitem.new(sitem_params)
    @sitem.vault_id = @vault_id
    if @sitem.save
      flash[:notice] = 'Item successfully added.'
      redirect_to(project_vaults_path) and return
    else
      render :new
    end
  end

  def edit
    @vault_id = params[:vault_id]

  end

  def update

  end

  def destroy
    @master = read_master_cache(User.current.id, @project.id)
    if @master.nil?
      # no master in cache
      redirect_to '/projects/' + @project.identifier + '/decrypt'
    else
      @sitem = Sitem.find(params[:id])
      @sitem.delete
      # refresh cache
      write_master_cache(User.current.id, @master, @project.id)
      redirect_to project_vaults_path
    end
  end

  def sitem_params
    params.require(:sitem).permit(:sitem_type, :sitem, :notes)
  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
