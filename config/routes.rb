get 'vaults', :to => 'vaults#index'

resources :projects do
  resources :vaults
end

resources :projects do
  resources :masters
end
