Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "khroma#index"

  #genders interface routes
  resources :genders do
    resources :categories, only: [:index]
  end

  #categories interface routes
  resources :categories do
    resources :types, only: [:index]
  end

  #types interface routes
  resources :types do 
    resources :styles, only: [:index]
  end

  #styles%products interface routes
  resources :styles do
    resources :products, only: [:index]
  end

  #link to product::id not style/style:id/products
  resources :products, only: [:show]


  resources :khroma, only: [:index] do
    collection do
      get :pop_choices
      get :match
    end
  end
  #backstage routes
  namespace :admin do
    root "genders#index"
    resources :genders
    resources :categories
    resources :types
    resources :styles do
      resources :products
    end
  end
  
end
