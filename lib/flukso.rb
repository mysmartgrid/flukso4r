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


require 'forwardable'
require 'rubygems'
 
gem 'httparty', '~> 0.4.3'
require 'httparty'
 
module Flukso
  class FluksoError < StandardError
    attr_reader :data
 
    def initialize(data)
      @data = data
      super
    end
  end
 
  class RateLimitExceeded < FluksoError; end
  class Unauthorized < FluksoError; end
  class General < FluksoError; end
 
  class Unavailable < StandardError; end
  class InformFlukso < StandardError; end
  class NotFound < StandardError; end
  # Use only the encrypted endpoint.
  #BASE_SENSOR_URL = "https://api.flukso.net/sensor"
  API_VERSION="1.0"
end
 
directory = File.expand_path(File.dirname(__FILE__))
 
require File.join(directory, 'flukso', 'http_auth')
require File.join(directory, 'flukso', 'reading')
require File.join(directory, 'flukso', 'request')
require File.join(directory, 'flukso', 'api')
require File.join(directory, 'flukso', 'database')
require File.join(directory, 'flukso', 'export')
require File.join(directory, 'flukso', 'R')
require File.join(directory, 'flukso', 'plots')
