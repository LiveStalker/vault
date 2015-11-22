class Sitem < ActiveRecord::Base
  unloadable
  belongs_to :vault, :class_name => "Vault", :foreign_key => "vault_id"
end
