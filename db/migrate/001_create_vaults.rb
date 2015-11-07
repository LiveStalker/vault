class CreateVaults < ActiveRecord::Migration
  def change
    create_table :vaults do |t|
      t.string :host
      t.string :login
      t.string :password
      t.boolean :private
      t.integer :user_id
      t.integer :project_id
      t.string :notes
    end
  end
end
