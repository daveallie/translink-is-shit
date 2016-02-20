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
      time_selection = %Q((current_date + (("time"::time AT TIME ZONE 'UTC') AT TIME ZONE 'Australia/Brisbane')))
      order('"time"::time').group('"time"::time').pluck(time_selection, 'AVG("delay")').map{|t, d| [t, d.to_f]}
    end
  end
end
