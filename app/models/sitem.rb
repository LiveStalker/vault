class Sitem < ActiveRecord::Base
  unloadable
  belongs_to :vault, :class_name => "Vault", :foreign_key => "vault_id"
  attr_accessible :sitem_type, :sitem, :notes
  validates_presence_of :sitem_type, :sitem
end
