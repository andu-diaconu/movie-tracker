Rails.application.routes.draw do
  apipie
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Movies
  get 'movies/search', to: 'movies#search'
  get 'movies/:id', to: 'movies#show', as: 'movie'
end
