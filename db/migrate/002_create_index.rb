class CreateIndex < ActiveRecord::Migration
  def up
    add_index :vaults, :host
    add_index :vaults, :login
    add_index :vaults, :password
    add_index :vaults, :private
    add_index :vaults, :user_id
    add_index :vaults, :project_id
  end

  def down
    remove_index :vaults, :host
    remove_index :vaults, :login
    remove_index :vaults, :password
    remove_index :vaults, :private
    remove_index :vaults, :user_id
    remove_index :vaults, :project_id
  end
end
