require 'thor'
require 'awesome_print'
require 'inifile'
require 'colorize'

module DLDInternet
  module AWS
    module EC2
      module Instance_Types

        LOG_LEVELS = [:trace, :debug, :info, :note, :warn, :error, :fatal, :todo]

        module MixIns
          module NoCommands
            require 'dldinternet/mixlib/logging'
            include DLDInternet::Mixlib::Logging

            def validate_options
              _options = options.dup
              if options[:log_level]
                log_level = options[:log_level].to_sym
                raise "Invalid log-level: #{log_level}" unless LOG_LEVELS.include?(log_level)
                _options[:log_level] = log_level
              else
                _options[:log_level] ||= :note
              end
              @options = _options
            end

            def parse_options
              validate_options

              lcs = ::Logging::ColorScheme.new( 'compiler', :levels => {
                  :trace => :blue,
                  :debug => :cyan,
                  :info  => :green,
                  :step  => :green,
                  :warn  => :yellow,
                  :error => :red,
                  :fatal => :red,
                  :todo  => :purple,
              })
              scheme = lcs.scheme
              scheme['trace'] = "\e[38;5;33m"
              scheme['fatal'] = "\e[38;5;89m"
              scheme['todo']  = "\e[38;5;55m"
              lcs.scheme scheme
              @config         = @options.dup
              @config[:log_opts] = lambda{|mlll| {
                  :pattern      => "%#{mlll}l: %m %g\n",
                  :date_pattern => '%Y-%m-%d %H:%M:%S',
                  :color_scheme => 'compiler',
                  :trace        => (@config[:trace].nil? ? false : @config[:trace]),
                  # [2014-06-30 Christo] DO NOT do this ... it needs to be a FixNum!!!!
                  # If you want to do ::Logging.init first then fine ... go ahead :)
                  # :level        => @config[:log_level],
              }
              }
              @logger = getLogger(@config)

              if @options[:inifile]
                @options[:inifile] = File.expand_path(@options[:inifile])
                unless File.exist?(@options[:inifile])
                  raise "#{@options[:inifile]} not found!"
                end
                begin
                  ini = ::IniFile.load(@options[:inifile])
                  ini['global'].each{ |key,value|
                    @options[key.to_s]=value
                  }
                  def _expand(k,v,regex,rerun)
                    matches = v.match(regex)
                    if matches
                      var = matches[1]
                      if options[var]
                        options[k]=v.gsub(/\%\(#{var}\)/,options[var]).gsub(/\%#{var}/,options[var])
                      else
                        rerun[var] = 1
                      end
                    end
                  end

                  pending = nil
                  rerun = {}
                  begin
                    pending = rerun
                    rerun = {}
                    options.to_hash.each{|k,v|
                      if v.to_s.match(/\%/)
                        _expand(k,v,%r'[^\\]\%\((\w+)\)', rerun)
                        _expand(k,v,%r'[^\\]\%(\w+)',     rerun)
                      end
                    }
                    # Should break out the first time that we make no progress!
                  end while pending != rerun
                rescue ::IniFile::Error => e
                  # noop
                rescue ::Exception => e
                  @logger.error "#{e.class.name} #{e.message}"
                  raise e
                end
              end

              if options[:verbose]
                @logger.info "Options:\n#{options.ai}"
              end

            end

          end
        end
      end
    end
  end
end