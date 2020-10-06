Rails.application.routes.draw do
  get "home/show"
  get "static/welcome"
  get "home/test"
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :owners
  resources :players
  resources :fantasy_teams
  resources :purchases

  resources :users_management

  devise_for :users,
             path: "",
             path_names: {
               sign_in: "login",
               sign_out: "logout",
               registration: "signup",
             },
             controllers: {
               sessions: "sessions",
               registrations: "registrations",
             }
end
