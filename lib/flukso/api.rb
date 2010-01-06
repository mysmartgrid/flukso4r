###
## 
# flukso4r: A Ruby library for Flukso 
# Copyright (C) 2010 Mathias Dalheimer (md@gonium.net)
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#  
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
##
###


module Flukso
  class QueryReadings
    def initialize(alias_id, timerange=:hour, unit=:watt)
      @alias_id=alias_id;
      # sanity checks.
      valid_timeranges=[:hour, :day, :month, :year];
      valid_units=[:watt, :kwh, :eur, :aud];
      raise Flukso::General, "Invalid timerange #{timerange}" unless valid_timeranges.include?(timerange);
      raise Flukso::General, "Invalid unit #{unit}" unless valid_units.include?(unit);
      @timerange=timerange;
      @unit=unit;
    end
    def execute(api)
      if api.class != Flukso::API
        raise  Flukso::General, "Cannot execute query: API object invalid"
      end
      query_url="#{Flukso::BASE_SENSOR_URL}/#{@alias_id}/#{@timerange}/#{@unit}";
      puts "Using query url #{query_url}" if $verbose
      response = api.perform_get(query_url) 
      return wrap_response(response);
    end
    def wrap_response(response)
      # The response is an array of arrays. Convert it to UTCReadings.
      retval=Array.new();
      response.each{|reading|
        current=UTCReading.new(reading[0].to_i, reading[1].to_i);
        retval << current;
      }
      return retval
    end
  end

  class UTCReading
    attr_accessor :utc_timestamp, :value
    def initialize(utc_timestamp, value)
      # sanity checks.
      raise Flukso::General, "Invalid reading timestamp: #{utc_timestamp}" if utc_timestamp.class != Bignum || utc_timestamp < 0;
      # TODO: Think about behavior when NaN is reported by the
      # webservice.
      #raise Flukso::General, "Invalid reading value: #{value}" if value.class != Fixnum || value < 0;
      @utc_timestamp = utc_timestamp;
      @value = value
    end
    def to_s
      return "#{@utc_timestamp} -> #{@value}"
    end
  end

  class API
    extend Forwardable

    def_delegators :client, :get, :post, :put, :delete

    attr_reader :client

    def initialize(client)
      @client = client
    end

    def perform_get(path, options={})
      Flukso::Request.get(self, path, options)
    end

    def perform_post(path, options={})
      Flukso::Request.post(self, path, options)
    end

    def perform_put(path, options={})
      Flukso::Request.put(self, path, options)
    end

    def perform_delete(path, options={})
      Flukso::Request.delete(self, path, options)
    end
  end
end
