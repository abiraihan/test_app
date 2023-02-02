class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations do |t|
      t.string :name
      t.column :geoms, :geometry, :srid => 4326
      t.timestamps
    end
    change_table :locations do |t|
      t.index :geoms, using: :gist
    end
  end
end
