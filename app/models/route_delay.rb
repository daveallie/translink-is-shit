class RouteDelay < ActiveRecord::Base
  include Filterable
  scope :route, -> (route_id) {where('"route_id" like ?', "#{route_id}%")}
  scope :buses, -> {where("route_id ~* E'^[0-9]{3,4}(?:-[0-9]+)?$'")}

  def self.bus_routes
    routes = where("route_id ~* E'^[0-9]{3,4}(?:-[0-9]+)?$'").pluck('DISTINCT route_id')
    routes.map{|r| r.split('-').first}
  end
end
