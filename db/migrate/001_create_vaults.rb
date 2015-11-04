class CreateVaults < ActiveRecord::Migration
  def change
    create_table :vaults do |t|
      t.string :host
      t.string :login
      t.string :password
      t.boolean :shared
      t.integer :user_id
      t.string :notes
    end
  end
end
