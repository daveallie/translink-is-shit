class CreateRouteDelays < ActiveRecord::Migration
  def change
    create_table :route_delays do |t|
      t.datetime :time, null: false
      t.string :route_id, null: false
      t.integer :delay, null: false
    end
  end
end
