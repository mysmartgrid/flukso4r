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

  DB_READINGS_NAME="powerreadings"
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
      return FluksoDB.new(db);
    end
    # open an existing database
    def self.open(filename)
      filename=File.expand_path(filename);
      if not File.exists?(filename)
        raise "Database file #{filename} does not exist."
      end
      db = SQLite3::Database.open( filename)
      return FluksoDB.new(db);
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
    def initialize(db)
      @db=db;
      @db.results_as_hash = true
    end
    def close
      @db.close;
    end
    def storeReading(reading)
      # TODO: Make this more efficient, recycle insert statements.
      if reading.class != UTCReading
        raise "Must give a UTCReading instance."
      end
      stmt=<<-SQL
      INSERT INTO #{DB_READINGS_NAME}
      VALUES ('#{reading.utc_timestamp}', '#{reading.value}'); 
      SQL
      @db.execute(stmt)
    end
    def find_reading_last_five
      return find_last_reading(5);
    end
    def find_last_reading(amount)
      if not amount.class==Fixnum
        raise "Must provide the number of last readings desired as an Fixnum."
      end
      stmt=<<-SQL
      SELECT * FROM #{DB_READINGS_NAME}
      order by epochtime DESC limit #{amount};
    SQL
        readings=Array.new
        @db.execute(stmt) {|row|
          value=row['VALUE'].to_f;
          timestamp=Time.at(row['EPOCHTIME'].to_f);
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
      SELECT * FROM #{DB_READINGS_NAME}
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
