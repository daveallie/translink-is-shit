require 'httparty'
require 'zlib'
require 'stringio'

class RetrieveExternalDb
  def initialize(url)
    @url = url
  end

  def import!
    import_stop_data!
    import_route_data!
  end

  private
  def import_stop_data!
    max_stop_delays_id = StopDelay.maximum(:id) || -1
    Rails.logger.debug("Getting stop data rows with id > #{max_stop_delays_id}")
    resp = HTTParty.get("#{@url}/stop_data/recent/#{max_stop_delays_id}")
    if resp.success?
      new_rows = JSON.parse(Zlib::GzipReader.new(StringIO.new(resp.parsed_response)).read)
      new_models = new_rows.map do |row|
        StopDelay.new({
            id: row['id'],
            time: Time.zone.at(row['time']),
            stop_id: row['stop_id'],
            delay: row['delay']
        })
      end
      StopDelay.import(new_models)
      Rails.logger.info("Imported #{new_models.count} new stop_delays rows")
    else
      Rails.logger.error('Failed to get stop data')
    end
  end

  def import_route_data!
    max_route_delays_id = RouteDelay.maximum(:id) || -1
    Rails.logger.debug("Getting route data rows with id > #{max_route_delays_id}")
    resp = HTTParty.get("#{@url}/route_data/recent/#{max_route_delays_id}")
    if resp.success?
      new_rows = JSON.parse(Zlib::GzipReader.new(StringIO.new(resp.parsed_response)).read)
      new_models = new_rows.map do |row|
        RouteDelay.new({
            id: row['id'],
            time: Time.zone.at(row['time']),
            route_id: row['route_id'],
            delay: row['delay']
        })
      end
      RouteDelay.import(new_models)
      Rails.logger.info("Imported #{new_models.count} new route_delays rows")
    else
      Rails.logger.error('Failed to get route data')
    end
  end
end
