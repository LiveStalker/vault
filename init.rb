Redmine::Plugin.register :password_vault do
  name 'Password Vault plugin'
  author 'Alexey V. Grebenshchikov'
  version '0.1.1'

  menu :project_menu,
       :vaults,
       {:controller => 'vaults', :action => 'index'},
       :caption => 'Vault',
       :after => :settings,
       :param => :project_id

  project_module :vaults do
    permission :view_passwords, {:vaults => :index, :master => [:decrypt, :decrypt_post]}
    permission :add_passwords, {:vaults => [:new, :create]}
    permission :edit_password, {:vaults => [:edit, :update]}
    permission :master_password, {:masters => [:new, :create, :decrypt, :decrypt_post]}
  end
end
