resources :projects do
  resources :vaults
end

resources :projects do
  resources :masters
end

get 'projects/:project_id/decrypt', :to => 'masters#decrypt'
post 'projects/:project_id/decrypt', :to=> 'masters#decrypt_post'
