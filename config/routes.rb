Rails.application.routes.draw do
  get 'home/show'
  get "static/welcome"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :owners
  resources :players
  resources :fantasy_teams
  resources :purchases
end
