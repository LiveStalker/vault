Redmine::Plugin.register :password_vault do
  name 'Password Vault plugin'
  author 'Alexey V. Grebenshchikov'
  version '0.0.1'

  menu :project_menu,
       :vaults,
       {:controller => 'vaults', :action => 'index'},
       :caption => 'Vault',
       :after => :settings,
       :param => :project_id

  project_module :vaults do
    permission :view_vault, :vaults => :index
    permission :add_vault, :vaults => [:new, :create]
    permission :master_password, :masters => [:new, :create]
  end
end
