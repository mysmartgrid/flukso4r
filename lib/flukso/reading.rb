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
 
  class UTCReading
    attr_accessor :utc_timestamp, :value
    def initialize(utc_timestamp, value)
      # sanity checks.
      raise Flukso::General, "Invalid reading timestamp: #{utc_timestamp}" if utc_timestamp < 0; 
      #raise Flukso::General, "Invalid reading value: #{value}" if value.class != Fixnum || value < 0;
      @utc_timestamp = utc_timestamp.to_i;
      if value =~ /^nan$/i
        @value=0.0/0.0  # Workaround: Ruby does not allow to assign NaN directly.
      else
        @value = value
      end
    end
    def to_s
      return "#{@utc_timestamp} -> #{@value}"
    end
  end

end