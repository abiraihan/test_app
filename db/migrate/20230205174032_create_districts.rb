class CreateDistricts < ActiveRecord::Migration[7.0]
  def change
    create_table :districts do |t|
      t.references :country, null: false, foreign_key: true
      t.string :name
      t.string :districts
      t.multi_polygon :geom, :srid => 4326
      t.timestamps
    end
    change_table :districts do |t|
      t.index :geom, using: :gist
    end
  end
end
