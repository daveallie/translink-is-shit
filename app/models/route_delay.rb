class RouteDelay < ActiveRecord::Base
  include Filterable
  scope :route, -> (route_id) {where('"route_id" like ?', "#{route_id}%")}
end
