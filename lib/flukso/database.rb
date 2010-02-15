###
##
# flukso4r: A Ruby library for Flukso 
# (c) 2010 Mathias Dalheimer, md@gonium.net
#
# Flukso4r is free software; you can 
# redistribute it and/or modify it under the terms of the GNU General Public 
# License as published by the Free Software Foundation; either version 2 of 
# the License, or any later version.
#
# Flukso4r is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CGWG; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

module Flukso
  require 'sqlite3'
  require 'flukso'

  DB_SCHEMA=<<-SQL
    create table :::TABLE_NAME::: (
      EPOCHTIME integer primary key,
      VALUE integer not null
    );
SQL


  class FluksoDB
    # create a new database
    def self.create(filename, tablename)
      filename=String.new(File.expand_path(filename));
      if File.exists?(filename)
        raise "Database file #{filename} already exists."
      end
      puts "Creating new database file #{filename}" if $verbose
      db = SQLite3::Database.open(filename)
      schema = FluksoDB.fill_template( DB_SCHEMA, { 'TABLE_NAME' => tablename} )
      db.execute_batch(schema)
      return FluksoDB.new(db, tablename);
    end
    # open an existing database
    def self.open(filename, tablename)
      filename=File.expand_path(filename);
      if not File.exists?(filename)
        raise "Database file #{filename} does not exist."
      end
      db = SQLite3::Database.open( filename)
      return FluksoDB.new(db, tablename);
    end
    # See: http://freshmeat.net/articles/templates-in-ruby
    # template: Returns a string formed from a template and replacement values
    #
    # templateStr - The template string (format shown below)
    # values - A hash of replacement values
    #
    # Example format:
    #   "Dear :::customer:::,\nPlease pay us :::amount:::.\n"
    #
    # The "customer" and "amount" strings are used as keys to index against the
    # values hash.
    #
    def self.fill_template( templateStr, values )
      outStr = templateStr.clone()
      values.keys.each { |key|
        outStr.gsub!( /:::#{key}:::/, values[ key ] )
      }
      outStr
    end
    # constuctor: give SQLite::Database object as argument. see class
    # methods.
    def initialize(db, tablename)
      @tablename=tablename
      @db=db;
      @db.results_as_hash = true
    end
    def close
      @db.close;
    end
    # Appends the readings of the provided array to the database.
    def appendNewReadings(readings)
      insertCounter=0
      last_timestamp=0
      begin
        last_reading=find_reading_last();
        last_timestamp=last_reading.utc_timestamp;
      rescue Flukso::ElementNotFoundError => e
        puts "Empty database - not able to provide last reading."
      end
      readings.each{|reading|
        if reading.utc_timestamp > last_timestamp
          puts "Appending #{reading}" if $verbose
          storeReading(reading);
          insertCounter += 1
        else
          puts "Skipping reading at #{reading.utc_timestamp}, already in DB." if $verbose
        end
      }
      return insertCounter
    end
    def storeReading(reading)
      # TODO: Make this more efficient, recycle insert statements.
      if reading.class != UTCReading
        raise "Must give a UTCReading instance."
      end
      stmt=<<-SQL
      INSERT INTO #{@tablename}
      VALUES ('#{reading.utc_timestamp}', '#{reading.value}'); 
      SQL
      @db.execute(stmt)
    end
    def find_reading_last_five
      return find_last_reading(5);
    end
    def find_reading_last
      return find_last_reading(1)[0];
    end
    def find_last_reading(amount)
      if not amount.class==Fixnum
        raise "Must provide the number of last readings desired as an Fixnum."
      end
      stmt=<<-SQL
      SELECT * FROM #{@tablename}
      order by epochtime DESC limit #{amount};
      SQL
      #puts "Using statement #{stmt}" if $verbose
      readings=Array.new
      @db.execute(stmt) {|row|
        value=row['VALUE'].to_f;
        #timestamp=Time.at(row['EPOCHTIME'].to_f);
        timestamp=row['EPOCHTIME'].to_f;
        #puts "Creating new UTCReading: #{timestamp}, #{value}"
        reading=UTCReading.new(timestamp, value);
        readings << reading
      }
      if readings.empty?
        raise ElementNotFoundError
      end
      return readings;
    end
    def find_reading_by_epochtime(time)
      stmt=<<-SQL
        SELECT * FROM #{@tablename}
        WHERE epochtime ='#{time}';
      SQL
      readings=Array.new
      @db.execute(stmt) {|row|
        reading=UTCReading.new(row['TIMESTAMP'].to_i, row['VALUE'].to_i)
        readings << reading
      }
      if readings.empty?
        raise ElementNotFoundError
      end
      return readings[0];
    end
  end

      class ElementNotFoundError < RuntimeError
      end
    end
