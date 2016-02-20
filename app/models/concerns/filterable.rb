module Filterable
  extend ActiveSupport::Concern

  included do
    scope :on_week_days, -> {where(%Q(EXTRACT(DOW FROM ("time" AT TIME ZONE 'UTC') AT TIME ZONE 'Australia/Brisbane') BETWEEN 1 AND 5))}
  end

  module ClassMethods
    def global_delay
      order(:time).group(:time).pluck(:time, 'AVG("delay")').map{|t, d| [t, d.to_f]}
    end

    def avg_global_delay
      # time_field = %Q((("time" AT TIME ZONE 'UTC') AT TIME ZONE 'Australia/Brisbane')::time)
      order = %Q(("time"::time AT TIME ZONE 'UTC') AT TIME ZONE 'Australia/Brisbane')
      time_selection = %Q(current_date + (#{order}))
      order(order).group('"time"::time').pluck(time_selection, 'AVG("delay")').map{|t, d| [t, d.to_f]}
    end
  end
end
