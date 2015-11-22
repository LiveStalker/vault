class SitemsController < ApplicationController
  unloadable
  include VaultsHelper
  before_filter :find_project, :authorize

  def new
    @vault_id = params[:vault_id]
    @sitem = Sitem.new
  end

  def create

  end

  def edit

  end

  def update

  end

  def destroy

  end

  def find_project
    @project = Project.find(params[:project_id])
  end
end
