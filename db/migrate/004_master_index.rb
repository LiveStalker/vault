class MasterIndex < ActiveRecord::Migration
  def up
    add_index :master_passwords, :project_id
  end

  def down
    remove_index :master_passwords, :project_id
  end
end
