class CreateStopDelays < ActiveRecord::Migration
  def change
    create_table :stop_delays do |t|
      t.datetime :time, null: false
      t.string :stop_id, null: false
      t.integer :delay, null: false
    end
  end
end
