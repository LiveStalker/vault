class AddProject < ActiveRecord::Migration
  def up
    add_column :vaults, :project_id, :integer
    add_index :vaults, :project_id
  end

  def down
    remove_column :vaults, :project_id, :integer
    remove_index :vaults, :project_id
  end
end
