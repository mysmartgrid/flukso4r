# This file is part of flukso4r
# (c) 2010 Mathias Dalheimer, md@gonium.net
#
# flukso4r is free software; you can 
# redistribute it and/or modify it under the terms of the GNU General Public 
# License as published by the Free Software Foundation; either version 2 of 
# the License, or any later version.
#
# FluksoBot is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with FluksoBot; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

module Flukso
  class UTC_Exporter
    def initialize()
      $stderr.puts("Using UTC Exporter");
    end
    def print_header()
      puts "timestamp\tvalue"
    end
    def format_reading(reading)
      puts "#{reading.utc_timestamp}\t#{reading.value}"
    end
  end
  class Local_Exporter
    def initialize()
      $stderr.puts("Using Local Time Exporter");
    end
    def print_header()
      puts "localtime\tvalue"
    end
    def format_reading(reading)
      puts "#{Time.at(reading.utc_timestamp)}\t#{reading.value}"
    end
  end
  class Detail_Exporter
    def initialize()
      $stderr.puts("Using Detail Exporter");
    end
    def print_header()
      puts "date \ttime\tdayofweek\tperiod\tvalue"
    end
    def format_reading(reading)
      currenttime=Time.at(reading.utc_timestamp);
      period=(currenttime.hour * 4) + (currenttime.min / 15);
      puts "#{currenttime.strftime("%Y-%m-%d\t%H:%M\t%a")}\t#{period}\t#{reading.value}"
    end
  end
end
