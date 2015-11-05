Redmine::Plugin.register :password_vault do
  name 'Password Vault plugin'
  author 'Alexey V. Grebenshchikov'
  version '0.0.1'

  #permission :vault, { :vault => [:index] }, :public => true
  menu :project_menu,
       :vault,
       {:controller => 'vault', :action => 'index'},
       :caption => 'Vault',
       :after => :settings,
       :param => :project_id

  project_module :vault do
    permission :view_vault, :vault => :index
  end
end
