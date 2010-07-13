# This file is part of Flukso4R
# (c) 2010 Mathias Dalheimer, md@gonium.net
#
# Flukso4R is free software; you can 
# redistribute it and/or modify it under the terms of the GNU General Public 
# License as published by the Free Software Foundation; either version 2 of 
# the License, or any later version.
#
# CGWG is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with CGWG; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

require "tempfile"
directory = File.expand_path(File.dirname(__FILE__))
require File.join(directory, 'plots')
#require "ruby-debug"

module Flukso
  # Run R without saving of environment, as quiet as possible.
  R_CMD = "Rscript --vanilla"  

  class RRunner
    def initialize(workingdir)
      # TODO: Check whether R command is available.
      @workingdir = workingdir
      puts "Using working directory #{@workingdir}" if $verbose
    end

    # returns a preamble string: which file to use etc.
    def createPreamble(outfilename)
      absOutFilename = File.expand_path(File.join(@workingdir, outfilename))
      cmd= <<-END_OF_CMD
      pdf("#{absOutFilename}");
    END_OF_CMD
      puts "using filename #{absOutFilename} for output." if $verbose
      return cmd
    end

    # returns a closing string - close file, terminate R
    def createClosing()
      close=<<-END_OF_CMD
      q()
    END_OF_CMD
      return close
    end

    # Executes the given command. Expects a string that contains the 
    # commands to execute.
    def executeCommandString(outfilename, commands) 
      cmdSet = createPreamble(outfilename)
      cmdSet << commands << createClosing
      # The Tempfile will get deleted automagically when ruby terminates.
      cmdfile=Tempfile.new("r-cmd", @workingdir)
      cmdfile.print(cmdSet)
      cmdfile.close()
      puts "executing commands:\n#{cmdSet}" if $verbose
      commandline="#{R_CMD} #{cmdfile.path}"
      puts "using commandline: #{commandline}" if $verbose
      stdout = %x[#{commandline}]
      puts "R (Exitcode: #{$?}) said: #{stdout}" if $verbose
    end

    def execute(outfilename, commands)
      puts commands.class
      if commands.class != Array
        raise "Please provide an array of commands to the execute call."
      end
      cmdString=""
      commands.each{|command|
        cmdString << command.cmd();
        cmdString << "# command separator\n"
      }
      executeCommandString(outfilename, cmdString);
    end

  end
end


# Test routines below - execute this file directly...
if __FILE__ == $0
  $verbose=true;
  runner=Flukso::RRunner.new(".");
  plotCmd=Flukso::TestPlot.new();
  plots=Array.new();
  plots << plotCmd;
  runner.execute("foo.pdf", plots);
end
