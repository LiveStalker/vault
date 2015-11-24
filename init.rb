Redmine::Plugin.register :password_vault do
  name 'Password Vault plugin'
  author 'Alexey V. Grebenshchikov'
  version '0.1.7'

  menu :project_menu,
       :vaults,
       {:controller => 'vaults', :action => 'index'},
       :caption => 'Vault',
       :after => :settings,
       :param => :project_id

  project_module :vaults do
    permission :view_passwords, {:vaults => [:index, :close_vault], :masters => [:decrypt, :decrypt_post], :sitems => [:new, :create, :edit, :update, :destroy]}
    permission :add_passwords, {:vaults => [:index, :new, :create, :close_vault], :masters => [:decrypt, :decrypt_post]}
    permission :edit_password, {:vaults => [:index, :new, :create, :edit, :update, :close_vault], :masters=> [:decrypt, :decrypt_post]}
    permission :delete_password, {:vaults => [:index, :new, :create, :edit, :update, :destroy, :close_vault], :masters=> [:decrypt, :decrypt_post]}
    permission :master_password, {:masters => [:new, :create, :change_master, :change_master_post]}, :public => true
  end

  settings :default => {'empty' => true}, :partial => 'settings/password_vault_settings'
end
