Rails.application.routes.draw do
  
  resources :email_campaigns do
    member do
      post :deliver
      get :status
    end
  end
  
end
