class Vault < ActiveRecord::Base
  unloadable
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :project, :class_name => "Project", :foreign_key => "project_id"
  attr_accessible :host, :login, :password, :notes
  validates_presence_of :host, :login, :password
end
