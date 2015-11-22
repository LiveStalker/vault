resources :projects do
  resources :vaults
end

resources :projects do
  resources :masters
end

resources :projects do
  resources :vaults do
    resources :sitems
  end
end

get 'projects/:project_id/decrypt', :to => 'masters#decrypt'
post 'projects/:project_id/decrypt', :to=> 'masters#decrypt_post'
get 'projects/:project_id/change-master', :to => 'masters#change_master'
post 'projects/:project_id/change-master', :to => 'masters#change_master_post'
get 'projects/:project_id/close-vault', :to => 'vaults#close_vault'
