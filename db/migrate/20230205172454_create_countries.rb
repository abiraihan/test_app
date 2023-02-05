class CreateCountries < ActiveRecord::Migration[7.0]
  def change
    create_table :countries do |t|
      t.string :name
      t.column :geom, :multi_polygon, :srid => 4326
      t.timestamps
    end
    change_table :countries do |t|
      t.index :name, unique: true
      t.index :geom, using: :gist
    end
  end
end
