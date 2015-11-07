class CreateMasterPasswords < ActiveRecord::Migration
  def change
    create_table :master_passwords do |t|
      t.string :password
      t.integer :project_id
    end
  end
end
