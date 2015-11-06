get 'vault', :to => 'vault#index'

resources :projects do
  resources :vault
end

resources :projects do
  resources :master
end
