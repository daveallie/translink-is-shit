Rails.application.routes.draw do
  get '/' => 'home#index'
  get '/route/:route_id' => 'home#get_route'
  get '/routes' => 'home#all_routes'
end
