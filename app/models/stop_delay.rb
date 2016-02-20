class StopDelay < ActiveRecord::Base
  include Filterable
  scope :stop, -> (stop_id) {where(stop_id: stop_id)}
end
