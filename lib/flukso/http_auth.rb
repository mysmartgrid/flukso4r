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
  class HTTPAuth
    include HTTParty
    format :plain

    attr_reader :username, :password, :options

    def initialize(username, password, options={})
      @username, @password = username, password
      @options = {:ssl => false}.merge(options)
      self.class.base_uri "http#{'s' if options[:ssl]}://api.flukso.net"
    end

    def get(uri, headers={})
      self.class.get(uri, :headers => headers, :basic_auth => basic_auth)
    end

    def post(uri, body={}, headers={})
      self.class.post(uri, :body => body, :headers => headers, :basic_auth => basic_auth)
    end

    def put(uri, body={}, headers={})
      self.class.put(uri, :body => body, :headers => headers, :basic_auth => basic_auth)
    end

    def delete(uri, body={}, headers={})
      self.class.delete(uri, :body => body, :headers => headers, :basic_auth => basic_auth)
    end

    private
    def basic_auth
      @basic_auth ||= {:username => @username, :password => @password}
    end
  end
end
