Kickerapp::Application.routes.draw do
  resources :matches do
    post :shuffle, on: :collection
    get :shuffle_select, on: :collection
  end
  resources :users

  get "/auth/:provider/callback" => "users#create"
  root :to => 'matches#index'
end
