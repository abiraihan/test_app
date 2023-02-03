# README

Create New Rails [v7.0.4.2] Application with PostgreSQL and enable PostGIS functionality into the database
  - Valid for below ditribution
    - Kali Linux - ```arm64-debian```

0.	**To Remove PostgreSQL from system, If necessary**
    - https://kb.objectrocket.com/postgresql/how-to-completely-uninstall-postgresql-757

1.	**Install PostgreSQL database**

    In Kali Linux (aarch-arm64), *PostgreSQL*  comes as Pre-Installed with the distribution but if you want to install it as a different varient then you can follow along the way here:

    - To check existing *PostgreSQL* Version
      - ```$ sudo apt show postgresql```
      - Start *PostgreSQL* service
        - ```$ sudo systemctl start postgresql```
      - Check Status of *PostgreSQL* service
        - ```$ sudo systemctl status postgresql```
    - To install *PostgreSQL* alog with *POSTGIS*
      - ```sudo apt install postgis postgresql-15-postgis-3```
      -	Check Path:  ```$ where pg_config```
    
    *Helpful Links to Install PostgreSQL with POSGIS*
      - https://computingforgeeks.com/how-to-install-postgis-on-debian/
      - https://techviewleo.com/how-to-install-postgresql-server-on-kali-linux/

2.	**Install POSTGIS with *GEOS, PROJ* functionality**

    *POSTGIS* require following dependencies to be installed into your local machine in order to function properly.

    - To install dependencies for *postgis* and find path of each installation:
      - Install GEOS: ```sudo apt install cmake clang libgeos-dev```
        - Check Version: ```geos-config --version```
        -	Check Path: ```$ where geos-config```
      - Install PROJ: ```sudo apt install proj```
        - Check version: ```proj --version```
        -	Check Path: ```$ where proj```
    
      *Helpful Links to Install POSGIS Dependencies*
        - https://www.cybertec-postgresql.com/en/postgis-upgrade-geos-with-ubuntu-in-3-steps/

3.	**Modify *pg_hba.conf* files for PostgreSQL give access to other application**

    *pg_hba.conf* file required to modify if other application require superuser/user access to the database. In order to provide access to all application, localhost *pg_hba.conf* require to modify. Follow below instruction to make those modification which will provide access to other application as necessary.

    - To find pg_hba.conf for postgresql
      - ```$ sudo -i -u postgres```
      - ```$ psql -t -P format=unaligned -c 'show hba_file';```
        - *example:* ```/etc/postgresql/15/main/pg_hba.conf```
    - In pg_hba.conf, change all local previleges to 'trust'/'md5' from 'peer'
      - ```local             all              all               all              trust/md5```

4.	**Create a *SUPERUSER* with same exact *app-name* into the database**

    Rails app database migration (database) require superuser previleges to access PostgreSQL database. Follow below as to create a new superuser for your rails application.

    - ```$ create role app-name with createdb login password 'password1';```
    - ```$ ALTER ROLE app-name WITH SUPERUSER;```

6.	**Start/Restart PosrgreSQL**

    After adding/changing role (superuser/user) into PostgreSQL Database, It require to restart, if PostgreSQL is not alreday started/restarted.

    - ```$ sudo systemctl restart postgresql```

7.	**Create a New Rails Application**

    While creating new application in Rails[7.0.4.2], please remember to have the same application name regarding the superuser role you already created into PostgreSQL. If your application name is different than your PostgreSQL Superuser name, you need to modify */config/database.yml* accordingly [See 9].

    - ```$ rails new app-name --database=postgresql```
    - Create a New Rails application with Bootstrap and Javascript bundling
      - ```$ rails new app-name -d postgresql -j esbuild --css bootstrap```

8.	**Add gem to gemfile**
    For postgis to work with your application you need add this below gem into your *Gemfile*
    - ```gem ‘Activerecord-postgis-adapter’```

9.	**Modify */config/database.yml* file in order to connect PostgreSQL database**

    After creating the new rails application, you need to provide authentication information to access PostgreSQL database from your rails application. Please also remember, default **adapter** params is **postgresql** which need to change as **postgis**

      ```
      default: &default
        adapter: postgis
        encoding: unicode
        username: app_name/superuser_name
        password: 123456
        schema_search_path: public
      ```

10.	**Create PostgreSQL Database: Create Tables**

    To create tables into PostgreSQL database for your application, run below command from your application directory
    - ```$ rails db:setup```

11.	**Add migration file to enable *POSTGIS* into PostgreSQL database for your application**

    - ```$ rails g migration add_postgis_to_database```
    - Add enable_extension ‘postgis’ into change def
      ```
      class AddPostgisToDatabase < ActiveRecord::Migration[7.0]
        def change
          enable_extension 'postgis'
        end
      end
      ```
    - ```$ rails db:migrate```

12. ***POSTGIS* is enabled for your rails application**
    - From application root directory
      - ```$ rails db```
      - ```$ \dt```
      - ```$ SELECT postgis_full_version();```
        - *If not available then enable extension by*
          - ```CREATE EXTENSION POSTGIS;```
          - Check Version ```SELECT PostGIS_version();```
      - To view any particular 'Table'
        - ```$ \d+ table-name```
      - To exit
        - ```$ \q```

12.	**Apply migration to your database to enable *POSTGIS* functionality from root app directory**
    - ```$ rails db:migrate```

13. **If required to rollback applied migration from database in rails application**
    - ```$ rails db:rollback```

14.	**Now Generate *Model* which will create table into the PostgreSQL database**

    Your model create a table into the database where data will be stored. This is the table which you manipulate for your application to store data.

    ***For example*** : If you name your model as *Location* which will create a table in database as *locations*
    - ```$ rails generate model model-name```
    - Your migration file is living here ```/db/migrate/``` with latest created model as a modified name
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
    - ```$ rails db:migrate```
    - Your ```/db/schema.rb``` file should look like this

      ```
      ActiveRecord::Schema[7.0].define(version: 2023_02_01_205447) do
        # These are extensions that must be enabled in order to support this database
        enable_extension "plpgsql"
        enable_extension "postgis"

        create_table "locations", force: :cascade do |t|
          t.string "name"
          t.geometry "geoms", limit: {:srid=>4326, :type=>"geometry"}
          t.datetime "created_at", null: false
          t.datetime "updated_at", null: false
          t.index ["geoms"], name: "index_locations_on_geoms", using: :gist
        end

      end
      ```

15.	***POSTGIS* Is Enabled and Functions Properly??**

    To check if *POSTGIS* is enabled, open rails console from application root directory
      - ```$ rails console```
      - Code Snippet:-
        ```
        3.0.0 :001 > geo = Location.new
        3.0.0 :002 > geo.name = "My Location"
        => "My Location"
        3.0.0 :003 > geo.geoms = "POINT(-122.657654 43.876543)"
        => "POINT(-122.657654 43.876543)"
        3.0.0 :004 > geo                                              
        id: nil,                                                                    
        name: "My Location",                                                        
        geoms: #<RGeo::Geos::CAPIPointImpl:0x3908 "POINT (-122.657654 43.876543)">, 
        created_at: nil,                                                            
        updated_at: nil>
        3.0.0 :005 > geo.geoms.factory
        => #<RGeo::Geos::CAPIFactory:0x1bd50 srid=4326 bufres=1 flags=8>                               
        3.0.0 :006 > geo.save
          TRANSACTION (0.4ms)  BEGIN
          Location Create (1.8ms)  INSERT INTO "locations" ("name", "geoms", "created_at", "updated_at") VALUES ($1, $2, $3, $4) RETURNING "id"  [["name", "My Location"], ["geoms", "0020000001000010e6c05eaa1700cd85594045f0328f9f44d4"], ["created_at", "2023-02-02 23:21:48.125802"], ["updated_at", "2023-02-02 23:21:48.125802"]]                                                
          TRANSACTION (4.7ms)  COMMIT                              
        => true
        ```
