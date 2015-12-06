class Vault < ActiveRecord::Base
  unloadable
  acts_as_attachable :view_permission => :view_files,
                     :edit_permission => :manage_files,
                     :delete_permission => :manage_files
  belongs_to :user, :class_name => "User", :foreign_key => "user_id"
  belongs_to :project, :class_name => "Project", :foreign_key => "project_id"
  has_many :sitems, :class_name => "Sitem", :dependent => :destroy
  attr_accessible :host, :login, :password, :notes, :private
  validates_presence_of :host, :login, :password

  def private_out
    private ? 'Yes' : 'No'
  end
end
