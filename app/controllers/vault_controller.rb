class VaultController < ApplicationController
  unloadable

  def index
    @project = Project.find(params[:project_id])
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
end
