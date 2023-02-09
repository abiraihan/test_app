puts 'Deleting all previous geographical data...'

connection = ActiveRecord::Base.connection()

District.delete_all
Country.delete_all

connection.execute "ALTER SEQUENCE districts_id_seq RESTART WITH 1"
connection.execute "ALTER SEQUENCE countries_id_seq RESTART WITH 1"

puts

if Country.all.count == 0
  puts 'Importing data for Bangladesh Division'

  connection.execute "drop table if exists countries_ref"
  from_country_shp_sql = `shp2pgsql -c -g geom -W LATIN1 -s 4326 #{Rails.root.join('db', 'shapefiles', 'gadm41_BGD_1.shp')} countries_ref`
  connection.execute "drop table if exists countries_ref"
  connection.execute from_country_shp_sql
  connection.execute <<-SQL
      insert into countries(name, geom, created_at, updated_at)
        SELECT name, geom, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP FROM countries_ref
  SQL
  connection.execute "drop table countries_ref"
end

# bangladesh_id = Country.all.first.id
# puts "Bangladesh country ID = #{bangladesh_id}"

# dam = Country.all

# dam.each do |record|
#   puts record.id
#   puts record.name
# end
puts

if District.all.count == 0
  puts 'Importing data for Bangladesh Districts'

  connection.execute "drop table if exists districts_ref"
  from_districts_shp_sql = `shp2pgsql -c -g geom -W LATIN1 -s 4326 #{Rails.root.join('db', 'shapefiles', 'gadm41_BGD_2.shp')} districts_ref`
  connection.execute "drop table if exists districts_ref"
  connection.execute from_districts_shp_sql
  connection.execute <<-SQL
      insert into districts(country_id, name, districts, geom, created_at, updated_at)
        select countries.id, districts_ref.name, districts_ref.district, districts_ref.geom, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP from districts_ref
        join countries
        on districts_ref.name = countries.name
  SQL
  connection.execute "drop table districts_ref"

  puts
end

# se = District.where(District.arel_table[:geom].st_within(Country.find_by(name: 'Khulna').geom)).select(:id, :name, :districts)
