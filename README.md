# README

Create New Rails [v7.0.4.2] Application with PostgreSQL-PostGIS database: -
0.	To Remove Postgresql from system
	https://kb.objectrocket.com/postgresql/how-to-completely-uninstall-postgresql-757
1.	Install PostgreSQL database.
	https://computingforgeeks.com/how-to-install-postgis-on-debian/
	https://techviewleo.com/how-to-install-postgresql-server-on-kali-linux/
2.	Install Postgis with GEOS, PROJ functionality
	https://www.cybertec-postgresql.com/en/postgis-upgrade-geos-with-ubuntu-in-3-steps/
	For path of each installation:
i.	Where geos-config
ii.	Where proj
iii.	Where pg_config
3.	Change pg_hba.conf files from: /etc/postgresql/15/main/pg_hba.conf
  put all local previleges to 'trust' from 'peer'
4.	create role app-name with createdb login password 'password1';
5.	ALTER ROLE app-name WITH SUPERUSER;

6.	Restart Posrgresql
	$sudo systemctl restart postgresql
7.	rails new ‘$app-name’ –database=postgresql
8.	Add gem ‘Activerecord-postgis-adapter’ to gemfile
9.	Change adapter: postgis and add username (app-name) and Password into default
10.	$rails db:setup
11.	$rails g migration add_postgis_to_database
	Add enable_extension ‘postgis’ into change def
12.	$rails db:migrate
13.	$rails generate model ‘model-name’
	Add column name
	Add geometry column -> t.column :geoms, :geometry, :srid => 4326
14.	Continue ..

