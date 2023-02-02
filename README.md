# README

Create New Rails [v7.0.4.2] Application with PostgreSQL and enable PostGIS functionality into the database
  - Valid for below ditribution
    - Kali Linux - ```arm64-debian```

0.	**To Remove Postgresql from system**
    - https://kb.objectrocket.com/postgresql/how-to-completely-uninstall-postgresql-757

1.	**Install PostgreSQL database**

    In Kali Linux (aarch-arm64), comes with *PostgreSQL* Pre-Installed but if you want to install as different varient then you can follow along as below:

    - To check existing *PostgreSQL* Version
      - ```$ sudo apt show postgresql```
      - Start *PostgreSQL* service
        - ```$ sudo systemctl start postgresql```
      - Check Status of *PostgreSQL* service
        - ```$ sudo systemctl status postgresql```
    - To install Postgresql with Postgis
      - ```sudo apt install postgis postgresql-15-postgis-3```
      -	Check Path:  ```$ where pg_config```
    
    *Helpful Links to Install PostgreSQL with POSGIS*
      - https://computingforgeeks.com/how-to-install-postgis-on-debian/
      - https://techviewleo.com/how-to-install-postgresql-server-on-kali-linux/

2.	**Install Postgis with *GEOS, PROJ* functionality**

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

3.	**Modify *pg_hba.conf* files for postgresql to give access to other application**

    *pg_hba.conf* file required to modify if other application require superuser/user access to the database. In order to provide access to all application, localhost *pg_hba.conf* require to modify. Follow below instruction to make those modification which will provide access to other application as necessary.

    - To find pg_hba.conf for postgresql
      - ```$ sudo -i -u postgres```
      - ```$ psql -t -P format=unaligned -c 'show hba_file';```
        - *example:* ```/etc/postgresql/15/main/pg_hba.conf```
    - In pg_hba.conf, change all local previleges to 'trust'/'md5' from 'peer'
      - ```local       all        all         all        trust/md5```

4.	**Create a *SUPER USER* with same exact *app-name* into the database**

    Rails app database migration (database) require superuser previleges to access PostgreSQL database. Follow below as to create a new superuser for your rails application.

    - ```$ create role app-name with createdb login password 'password1';```
    - ```$ ALTER ROLE app-name WITH SUPERUSER;```

6.	**Start/Restart Posrgresql**

    After adding/changing role (superuser/user) into PostgreSQL Database, It require to restart, if PostgreSQL is not alreday started/restarted.

    - ```$ sudo systemctl restart postgresql```

7.	**Create a New rails application**

    While creating new application in Rails[7.0.4.2], please remember to have the same application name regarding the superuser role you already created into PostgreSQL. If your application name is different than your PostgreSQL Superuser name, you need to modify */config/database.yml* accordingly [See 9].

    - ```$ rails new app-name --database=postgresql```
    - Create a New Rails application with Bootstrap and Javascript bundling
      - ```$ rails new app-name -d postgresql -j esbuild --css bootstrap```

8.	**Add gem to gemfile**
    For postgis to work with your application you need add this below gem into your *Gemfile*
    - ```gem ‘Activerecord-postgis-adapter’```

9.	**In */config/database.yml* file, Change as**

    After creating the new rails application, you need to provide authentication information to access PostgreSQL database from your rails application. Please also remember, default **adapter** params is **postgresql** which need to change as **postgis**

      ```
      default: &default
        adapter: postgis
        encoding: unicode
        username: app_name/superuser_name
        password: 123456
        schema_search_path: public
      ```

10.	**Create Postgresql database: create 2 tables**

    To create tables into PostgreSQL database for your application, run below command from your application directory
    - ```$ rails db:setup```

11.	**Add migration file to enable postgis into postgresql database for your application**

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

12. **To check that *POSTGIS* is enabled**
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

12.	**Then migrate database from root app directory**
    - ```$ rails db:migrate```

13. **If required to rollback applied migration from database in rails app**
    - ```$ rails db:rollback```

14.	**Now Generate *Model* which will create table as the model name +'s' into the database**

    Your model create a table into the database where data will be stored. This is the table which you manipulate for your application to store data.

    ***For example*** : If you name your model as *Location* which will create a table in database as *locations*
    - ```$ rails generate model model-name```
    - Add column name from ```/db/migrate``` with latest created model name
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

15.	Continue ..

