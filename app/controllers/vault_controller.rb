class VaultController < ApplicationController
  unloadable

  before_filter :find_project, :authorize, :only => :index

  def index

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
