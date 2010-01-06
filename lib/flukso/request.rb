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
  class Request
    include HTTParty
    extend Forwardable

    def self.get(client, path, options={})
      new(client, :get, path, options).perform
    end

    def self.post(client, path, options={})
      new(client, :post, path, options).perform
    end

    def self.put(client, path, options={})
      new(client, :put, path, options).perform
    end

    def self.delete(client, path, options={})
      new(client, :delete, path, options).perform
    end

    attr_reader :client, :method, :path, :options

    def_delegators :client, :get, :post, :put, :delete

    def initialize(client, method, path, options={})
      @client, @method, @path, @options = client, method, path, {:mash => true}.merge(options)
    end

    def uri
      @uri ||= begin
                 uri = URI.parse(path)

                 if options[:query] && options[:query] != {}
                   uri.query = to_query(options[:query])
                 end

                 uri.to_s
               end
    end

    def perform
      make_friendly(send("perform_#{method}"))
    end

    private
    def perform_get
      send(:get, uri, options[:headers])
    end

    def perform_post
      send(:post, uri, options[:body], options[:headers])
    end

    def perform_put
      send(:put, uri, options[:body], options[:headers])
    end

    def perform_delete
      send(:delete, uri, options[:headers])
    end

    def make_friendly(response)
      puts "Raw Response from Flukso Server: #{response}" if $verbose
      raise_errors(response)
      data = parse(response)
      return data
    end

    def raise_errors(response)
      case response.code.to_i
      when 400
        data = parse(response)
        raise RateLimitExceeded.new(data), "(#{response.code}): #{response.message} - #{data['error'] if data}"
      when 401
        data = parse(response)
        raise Unauthorized.new(data), "(#{response.code}): #{response.message} - #{data['error'] if data}"
      when 403
        data = parse(response)
        raise General.new(data), "(#{response.code}): #{response.message} - #{data['error'] if data}"
      when 404
        raise NotFound, "(#{response.code}): #{response.message}"
      when 500
        raise InformFlukso, "Flukso had an internal error. Please let them know in the group. (#{response.code}): #{response.message}"
      when 502..503
        raise Unavailable, "(#{response.code}): #{response.message}"
      end
    end

    def parse(response)
      Crack::JSON.parse(response.body)
    end
  end
end
