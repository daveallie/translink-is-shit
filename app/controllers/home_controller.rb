class HomeController < ApplicationController
  def index
    @global = normalize_and_pad_data(RouteDelay.buses.on_week_days.avg_global_delay)
  end

  # get '/routes' => 'home#all_routes'
  def all_routes
    render json: RouteDelay.bus_routes, status: 200
  end

  # get '/route/:route_id' => 'home#get_route'
  def get_route
    res = if params[:route_id] == 'all'
      normalize_and_pad_data(RouteDelay.on_week_days.avg_global_delay)
    else
      normalize_and_pad_data(RouteDelay.route(params[:route_id]).on_week_days.avg_global_delay)
    end
    render json: res, status: 200
  end

  private
  def normalize_and_pad_data(data)
    data = data.map{|t, d| [t.in_time_zone('Brisbane').seconds_since_midnight.round, d.round]}
    (0..144).map{|t| [t*600, nil]}.to_h.merge(data.to_h).to_a
  end
end
