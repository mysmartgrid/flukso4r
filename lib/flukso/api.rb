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
    def initialize(sensor_id, timerange=:hour, unit=:watt)
      @sensor_id=sensor_id;
      # sanity checks.
      valid_timeranges=[:hour, :day, :month, :year, :night];
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
      query_url="/#{@sensor_id}?interval=#{@timerange}&unit=#{@unit}";
      #query_url="#{Flukso::BASE_SENSOR_URL}/#{@sensor_id}?interval=#{@timerange}&unit=#{@unit}";
      puts "Using query url #{query_url}" if $verbose
      response = api.perform_get(query_url) 
      return wrap_response(response);
    end
    def wrap_response(response)
      # The response is an array of arrays. Convert it to UTCReadings.
      retval=Array.new();
      response.each{|reading|
        current=UTCReading.new(reading[0], reading[1]);
        retval << current;
      }
      return retval
    end
  end

  class API
    extend Forwardable

    def_delegators :client, :get, :post, :put, :delete

    attr_reader :client

    def initialize(client, base_url)
      @client = client
      @base_url = base_url
    end
    
    def perform_get(path, options={})
      Flukso::Request.get(self, @base_url+path, options )
    end

    def perform_post(path, options={})
      Flukso::Request.post(self, @base_url+path, add_version_header(options))
    end

    def perform_put(path, options={})
      Flukso::Request.put(self, @base_url+path, add_version_header(options))
    end

    def perform_delete(path, options={})
      Flukso::Request.delete(self, @base_url+path, add_version_header(options))
    end

  end
end
