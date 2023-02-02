# README

Create New Rails [v7.0.4.2] Application with PostgreSQL-PostGIS database (aarch-arm64):- \
0.	To Remove Postgresql from system
  - https://kb.objectrocket.com/postgresql/how-to-completely-uninstall-postgresql-757 \
1.	Install PostgreSQL database.
    - https://computingforgeeks.com/how-to-install-postgis-on-debian/
    - https://techviewleo.com/how-to-install-postgresql-server-on-kali-linux/
2.	Install Postgis with GEOS, PROJ functionality
    - https://www.cybertec-postgresql.com/en/postgis-upgrade-geos-with-ubuntu-in-3-steps/
    - To find path of each installation: \
      i.	```$ where geos-config``` \
      ii.	```$ where proj``` \
      iii.	```$ where pg_config```
3.	Change pg_hba.conf files from: /etc/postgresql/15/main/pg_hba.conf
    - To find hba_file.conf for postgresql
      - Open PostgreSQL as user postgres
      - ```$ sudo -i -u postgres```
      - ```$ psql -t -P format=unaligned -c 'show hba_file';```
    - Change all local previleges to 'trust'/'md5' from 'peer'
    - ```local       all        all         all        trust/md5```
4.	Create a SUPER USER with same exact database as app-name
    - ```$ create role app-name with createdb login password 'password1';```
    - ```$ ALTER ROLE app-name WITH SUPERUSER;```
6.	Restart Posrgresql
    - ```$ sudo systemctl restart postgresql```
7.	Create a New rails application
    - ```$ rails new app-name --database=postgresql```
8.	Add gem to gemfile
    - ```gem ‘Activerecord-postgis-adapter’```
9.	In database.yml file, Change as;
    - adapter: postgis
    - username: (app-name)
    - Password: password (ex: 123456)
10.	Create Postgresql database
    - ```$ rails db:setup```
11.	Add migration file to enable postgis into postgresql database for your application

    - ```$ rails g migration add_postgis_to_database```
    - Add enable_extension ‘postgis’ into change def
    ```
    class AddPostgisToDatabase < ActiveRecord::Migration[7.0]
      def change
        enable_extension 'postgis'
      end
    end
    ```
12. To check that 'postgis' enabled,
    - From app root directory
      - ```$ rails db```
      - ```$ \dt```
      - ```$ SELECT postgis_full_version();```
      - To view any particular 'Table'
        - ```$ \d+ table```
      - To exit
        - ```$ \q```
12.	Then migrate database from root app directory
    - ```$ rails db:migrate```
13.	$rails generate model ‘model-name’
    - Add column name
    - Add geometry column or other column
      ```
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
      ```
14.	Continue ..

