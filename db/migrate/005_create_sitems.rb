class CreateSitems < ActiveRecord::Migration
  def change
    create_table :sitems do |t|
      t.string :sitem_type
      t.string :sitem
      t.string :notes
      t.integer :vault_id
    end
  end
end
