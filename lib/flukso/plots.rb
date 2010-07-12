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

module Flukso
  # a simple scatterplot
  class ScatterPlotDaily
    def initialize(annotation)
      @annotation=annotation;
      @readings=Array.new()
    end
    def addReading(reading);
      @readings << reading
    end
    def create_dataframe_cmd()
      cmd_create_dataframe= <<-END_OF_CMD
        dataset <- data.frame( 
          date=character(), 
          dayofweek=character(), 
          period=numeric(), 
          value=numeric() 
        );
      END_OF_CMD
      @readings.each{|reading|
        # calculate some values.
        currenttime=Time.at(reading.utc_timestamp);
        cmd_compose_data= <<-END_OF_CMD
          newline<-data.frame(#{reading.utc_timestamp}, "#{reading.dayOfWeek}", #{reading.period}, #{reading.value}); 
          colnames(newline)<- colnames(dataset);
          dataset <- rbind(dataset, newline);
        END_OF_CMD
        cmd_create_dataframe << cmd_compose_data;
      }
      return cmd_create_dataframe
    end
    def cmd()
      dataframe=create_dataframe_cmd();
      cmd= <<-END_OF_CMD
        # plot commmands. 
        library(lattice);
        y_max=max(dataset$value);
        title<-paste("Daily Power Consumption", "#{@annotation}");
        data_points<-paste("Number of data points:",nrow(dataset));
        cat("Plotting scatterplot:", title, data_points, "\n");
        xyplot(dataset$value ~ dataset$period, main=title, 
          ylab="Power Usage [W]", xlab="Time Period [15min Intervals]", 
          sub=data_points, ylim=c(0,y_max), xlim=c(0,95));
      END_OF_CMD
      return dataframe << cmd
    end
  end
  # Simple test plot that plots 100 points.
  class TestPlot
    def cmd()
      cmd= <<-END_OF_CMD
        v=1:100
        p=1:100
        plot(v,p)
      END_OF_CMD
      return cmd
    end
  end

end

# The following classes provide some ideas. Not used.
class RExperimentAnalysis
  def initialize(path, datafile, loadlevel)
    @workingdir=path
    @datafile = File.expand_path(File.join(path, datafile))
    @loadlevel = loadlevel
    puts "Using data from file #{@datafile}" if $verbose
    @runner = RRunner.new(path)
  end

  def plotSingleRun_Queuetimes
    drawcmd=<<-END_OF_CMD
      plot(data$stime, data$qtime,
        main="Queuetime for all jobs",
        xlab="submittime",
        ylab="queuetime"
      )
    END_OF_CMD
    outfile="queuetimes-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun_Price
    drawcmd=<<-END_OF_CMD
      plot(data$price,
        main="Price for all jobs",
        xlab="Job ID",
        ylab="price"
      )
    END_OF_CMD
    outfile="price-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun_PricePrefVsPrice()
    drawcmd=<<-END_OF_CMD
      plot(data$pricepref, data$pricert,
        main="Price preference vs. price per second",
        xlab="Price Preference",
        ylab="price/runtime [price/s]"
      )
    END_OF_CMD
    outfile="priceprefvspricert-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end 

  def plotSingleRun_PerfPrefVsQueueTime()
    drawcmd=<<-END_OF_CMD
      plot(data$perfpref, data$qtime,
        main="Performance preference vs. queuetime",
        xlab="Performance Preference",
        ylab="absolute queuetime [s]"
      )
    END_OF_CMD
    outfile="perfprefvsqtime-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun_PricePerSecond
    drawcmd=<<-END_OF_CMD
      plot(data$pricert,
        main="Price per second for all jobs",
        xlab="Job ID",
        ylab="price/runtime [price/s]"
      )
    END_OF_CMD
    outfile="pricepersecond-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun_PriceHistogram
    drawcmd=<<-END_OF_CMD
      hist(data$pricert,
        main="Histogram of prices per second",
        xlab="Price per second",
        ylab="Frequency"
      )
    END_OF_CMD
    outfile="histpricepersecond-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun_QueuetimeHistogram
    drawcmd=<<-END_OF_CMD
      hist(data$qtime,
        main="Histogram of queuetimes",
        xlab="Queuetime [s]",
        ylab="Frequency"
      )
    END_OF_CMD
    outfile="histqueuetimes-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun_perfPrefHistogram
    drawcmd=<<-END_OF_CMD
      hist(data$perfpref,
        main="Histogram of user preferences",
        xlab="Performance Preference",
        ylab="Frequency"
      )
    END_OF_CMD
    outfile="histperfpref-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end

  def plotSingleRun
    methods.grep(/^plotSingleRun_/){|m|
      self.send(m)
    }
    sleep(1)
  end
end


class PAES_Analysis
  def initialize(path, annotationsfile)
    @workingdir=path
    @annotationsfile=annotationsfile
    if @annotationsfile != nil
      @annotations=AnnotationCollection.new(@annotationsfile)
    end
    @runner = RRunner.new(path)
  end
  def plotSingleRun
    methods.grep(/^plotSingleRun_/){|m|
      self.send(m)
    }
    sleep(1)
  end
  def arrayToC(input)
    retval="c("
    input.each{|element|
      if element.instance_of?(String)
        retval += "\"#{element}\","
      else
        retval += "#{element},"
      end
    }
    retval.sub!(/,$/, "");   # delete the last comma
    return retval+")";
  end
  ###
  ## takes a drawcommand as an argument and adds annotations
  ## as needed.
  ## TODO: Points are not plotted if they are out of the range of
  ## the plot - this might be necessary in the future.
  #
  def appendAnnotations(drawcmd)
    if @annotations != nil
      puts "Adding annotations\n#{@annotations.to_s}"
      colors=Array.new()
      labels=Array.new()
      ltyInfo=Array.new()
      pchInfo=Array.new()
      counter=0;
      pointlines=""
      @annotations.each{|a|
        counter+=1;
        colors << counter;
        labels << a.text;
        pointlines+="points(#{a.qt}, #{a.price}, type=\"p\", pty=2, col=#{counter})\n"
        ltyInfo << -1;
        pchInfo << 1;
      }
      cols=arrayToC(colors)
      labelList=arrayToC(labels)
      ltyList=arrayToC(ltyInfo)
      pchList=arrayToC(pchInfo)
      drawcmd+=<<-EOC
        cols=#{cols}
        labels=#{labelList}
        #{pointlines}
        legend("topright", labels, col = cols,
           text.col = "black", lty = #{ltyList}, pch = #{pchList},
           bg = 'gray90')
      EOC
    end
    return drawcmd
  end
  def plotSingleRun_ParetoSchedules_Absolute
    basename="absolute-results"
    #main="Pareto Front (absolute values)",
    drawcmd=<<-END_OF_CMD
      plot(data$QT, data$Price, type="b",
        xlab="queue time (s)",
        ylab="price"
      )
    END_OF_CMD
    infile=File.join(@workingdir, basename+".txt")
    outfile=basename+".eps"
    puts "infile: #{infile}"
    puts "outfile: #{outfile}"
    @runner.execute(infile, outfile, drawcmd)
  end
  def plotSingleRun_ParetoSchedules_Relative
    basename="relative-results"
    max_qt_annotation = @annotations.getMaxQT()
    max_price_annotation = @annotations.getMaxPrice()
    min_qt_annotation = @annotations.getMinQT()
    min_price_annotation = @annotations.getMinPrice()
    puts "### Calculated: #{max_qt_annotation}, #{max_price_annotation}"
    #main="Pareto Front (relative values)",
    drawcmd=<<-END_OF_CMD
      max_qt<-max(data$QT, #{max_qt_annotation});
      max_price<-max(data$Price, #{max_price_annotation});
      min_qt<-min(data$QT, #{min_qt_annotation});
      min_price<-min(data$Price, #{min_price_annotation});
      qt_range<-c(min_qt,max_qt);
      price_range<-c(min_price,max_price);
      plot(qt_range, price_range, type="n",
        xlab="queue time (s)",
        ylab="price / second"
      )
      points(data$QT, data$Price, type="b")
    END_OF_CMD
    drawcmd=appendAnnotations(drawcmd)
    infile=File.join(@workingdir, basename+".txt")
    outfile=basename+".eps"
    puts "infile: #{infile}"
    puts "outfile: #{outfile}"
    @runner.execute(infile, outfile, drawcmd)
  end
  def plotSingleRun_Runtime
    basename="runtime-report"
    drawcmd=<<-END_OF_CMD
      l<-length(data$acc)
      range<-1:l
      plot(range, data$acc, type="n",
        xlab="Iteration (x 1000)",
        ylab="Dominant Solutions"
      )
      points(range, data$acc, type="l", lty=1)
    END_OF_CMD
    infile=File.join(@workingdir, basename+".txt")
    outfile=basename+".eps"
    puts "infile: #{infile}"
    puts "outfile: #{outfile}"
    @runner.execute(infile, outfile, drawcmd)
  end
  def plotSingleRun_Runtime_Distance
    basename="runtime-report"
    drawcmd=<<-END_OF_CMD
      l<-length(data$distance)
      range<-1:l
      plot(range, data$distance, type="n",
        xlab="Iteration (x 1000)",
        ylab="Distance"
      )
      points(range, data$distance, type="l", lty=2)
    END_OF_CMD
    infile=File.join(@workingdir, basename+".txt")
    outfile=basename+"-distance.eps"
    puts "infile: #{infile}"
    puts "outfile: #{outfile}"
    @runner.execute(infile, outfile, drawcmd)
  end

  def plotSingleRun_ParetoSchedules_Intermediates
    # Search for all intermediate-* files in the data directory
    Dir.foreach(@workingdir) {|file|
      #puts "checking #{file}"
      if file =~ /^intermediate-/
        if not file =~ /.eps$/
          plotIntermediate(file)
        end
      end
    }
  end
  def plotIntermediate(filename)
    drawcmd=<<-END_OF_CMD
      plot(data$QT, data$Price, type="b",
        main="Pareto Front (absolute values)",
        xlab="queue time (s)",
        ylab="price"
      )
    END_OF_CMD
    infile=File.join(@workingdir, filename)
    outfile=filename+".eps"
    puts "infile: #{infile}"
    puts "outfile: #{outfile}"
    @runner.execute(infile, outfile, drawcmd)
  end

end



class SA_Analysis
  def initialize(path, datafile, loadlevel)
    @workingdir=path
    @datafile = File.expand_path(File.join(path, datafile))
    @loadlevel = loadlevel
    puts "Using data from file #{@datafile}" if $verbose
    @runner = RRunner.new(path)
  end
  def plotSingleRun
    methods.grep(/^plotSingleRun_/){|m|
      self.send(m)
    }
    sleep(1)
  end
  def plotSingleRun_Energy
    drawcmd=<<-END_OF_CMD
      l<-length(data$Energy)
      range<-1:l
      plot(range, data$Energy, type="n",
        main="Energy of the Solutions",
        xlab="Iteration",
        ylab="Absolute Energy"
      )
      points(range, data$Energy)
    END_OF_CMD
    outfile="sa-energy-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end
  def plotSingleRun_Temperature
    drawcmd=<<-END_OF_CMD
      l<-length(data$Temperature)
      range<-1:l
      plot(range, data$Temperature, type="n",
        main="Temperature of the Solutions",
        xlab="Iteration",
        ylab="Temperature"
      )
      points(range, data$Temperature, pch=1)
    END_OF_CMD
    outfile="sa-temperature-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end
  def plotSingleRun_Accepted
    drawcmd=<<-END_OF_CMD
      l<-length(data$Accepted)
      range<-1:l
      plot(range, data$Accepted, type="n",
        main="Number of Accepted Solutions",
        xlab="Iteration",
        ylab="# Accepted"
      )
      points(range, data$Accepted, pch=1)
    END_OF_CMD
    outfile="sa-accepted-"+@loadlevel.to_s
    @runner.execute(@datafile, outfile, drawcmd)
  end
end

