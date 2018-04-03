Rails.application.routes.draw do
  devise_for :users, controllers: { 
    omniauth_callbacks: "users/omniauth_callbacks",
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  
  root "khroma#index"

  resources :users, only: [:edit, :update, :show] do
    resources :carts, only: [:index]
  end

  resources :carts, only: [:create, :destroy]

  #genders interface routes
  resources :genders, only: [:index]  do
    resources :categories, only: [:index]
  end

  #categories interface routes
  resources :categories, only: [] do
    resources :types, only: [:index]
  end

  #types interface routes
  resources :types, only: [] do 
    resources :styles, only: [:index] do
      collection do
        get :price_order_desc
        get :price_order_asc
        get :brand_order
     end
    end
  end

  #styles%products interface routes
  resources :styles, only: [] do
    member do
      get :change_color
    end
  end

  #link to product::id not style/style:id/products
  resources :products, only: [:show] do
    member do
      get :family
      get :change_color
      get :change_style_next
      get :change_style_previous
    end
  end

  resources :khroma, only: [:index] do
    collection do
      get :navbar
      get :pop_gender_choices
      get :pop_category_choices
      get :match
    end
  end
  #backstage routes
  namespace :admin do
    root "genders#index"

    resources :genders, except: [:show, :new]  do
      resources :categories, only: [:index]
    end

    resources :categories, except: [:show, :new] do
      resources :types, only: [:index]
    end

    resources :types, except: [:show, :new] do
      resources :styles, only: [:index]
    end

    resources :styles, except: [:show, :new] do
      resources :products, except: [:show, :new]
    end
    resources :products, only: [:edit, :update, :destroy]
  end
  
end
