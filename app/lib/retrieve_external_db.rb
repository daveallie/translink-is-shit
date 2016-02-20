require 'tempfile'
require 'httparty'
require 'sqlite3'

class RetrieveExternalDb
  def initialize(url)
    @url = url
  end

  def import!
    file = download
    if file
      restore(file)
    else
      Rails.logger.error('No file was downloaded!')
    end
  end

  private
  def download
    db_file = Tempfile.new('db_dump', Rails.root.join('tmp'))
    db_file.binmode
    db_file.write HTTParty.get(@url).parsed_response
    db_file.close
    db_file
  end

  def restore(db_file)
    max_stop_delays_id = StopDelay.maximum(:id) || -1
    max_route_delays_id = RouteDelay.maximum(:id) || -1
    begin
      db = SQLite3::Database.open(db_file.path)
      new_stop_delays = db.execute('SELECT * FROM stop_delays WHERE id > ?', max_stop_delays_id).map do |row|
        StopDelay.new({
            id: row[0],
            time: Time.zone.at(row[1]),
            stop_id: row[2],
            delay: row[3]
        })
      end

      new_route_delays = db.execute('SELECT * FROM route_delays WHERE id > ?', max_route_delays_id).map do |row|
        RouteDelay.new({
            id: row[0],
            time: Time.zone.at(row[1]),
            route_id: row[2],
            delay: row[3]
        })
      end

      StopDelay.import(new_stop_delays)
      RouteDelay.import(new_route_delays)

      # StopDelay.transaction do
      #   new_stop_rows.map do |row|
      #     StopDelay.new(row)
      #   end
      # end

      # RouteDelay.transaction do
      #   new_route_rows.map do |row|
      #     RouteDelay.create(row)
      #   end
      # end
    rescue Exception => e
        Rails.logger.error('failed to import data')
        Rails.logger.error(e.message)
        Rails.logger.error(e.backtrace)
    ensure
      db_file.unlink
    end
  end
end
