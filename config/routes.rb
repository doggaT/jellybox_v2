Rails.application.routes.draw do
  resources :directories
  devise_for :users
  get 'about/index'
  get '/about', to: 'about#index'
  resources :directories do
    member do
      get 'new_subdirectory'
      post 'attach_files'
      post 'create_subdirectory'
      post 'directories', to: 'directories#create'
      delete '/directories/:id/attachments/:attachment_id', to: 'directories#delete_attachment', as: 'delete_attachment'
      delete 'delete_directory', to: 'directories#destroy', as: 'destroy'
    end
  end

  root 'home#index'
  get 'users/index'
  match '/users', to: 'users#index', via: 'get'
  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
end
