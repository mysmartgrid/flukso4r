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
  class TokenAuth
    include HTTParty
    format :plain

    attr_reader :options

    def initialize(access_token)
      @access_token = access_token
      #@options = {:ssl => true}.merge(options)
      self.class.base_uri "#{Flukso::BASE_SENSOR_URL}"
    end

    
    def get(uri, headers={})
      headers=add_auth_header(headers);
      self.class.get(uri, :headers => headers)
    end

    def post(uri, body={}, headers={})
      self.class.post(uri, :body => body, :headers => add_auth_header(headers))
    end

    def put(uri, body={}, headers={})
      self.class.put(uri, :body => body, :headers => add_auth_header(headers))
    end

    def delete(uri, body={}, headers={})
      self.class.delete(uri, :body => body, :headers => add_auth_header(headers))
    end

    private

    def add_version_header(headers)
      if (headers==nil)
      else
        headers={"X-Version" => "#{Flukso::API_VERSION}"}.merge(headers);
      end
      return headers;
    end


    def add_auth_header(headers)
      if (headers==nil)
        headers={"X-Version" => "#{Flukso::API_VERSION}"}
        headers.merge!({"X-Token" => "#{@access_token}"})
      else
        headers={"X-Version" => "#{Flukso::API_VERSION}"}.merge(headers);
        headers={"X-Token" => "#{@access_token}"}.merge(headers);
      end
      return headers;
    end

  end
end
