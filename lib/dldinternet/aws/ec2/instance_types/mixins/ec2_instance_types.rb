require 'thor'
require 'awesome_print'
require 'inifile'
require 'colorize'
require 'dldinternet/aws/ec2/instance_types/scraper'

module DLDInternet
  module AWS
    module EC2
      module Instance_Types
        module MixIns
          module EC2_Instance_Types

            def getFileFormat(path)
              format = case File.extname(File.basename(path)).downcase
                         when /json|js/
                           'json'
                         when /yaml|yml/
                           'yaml'
                         else
                           raise DLDInternet::AWS::EC2::Instance_Types::Error.new("Unsupported file type: #{path}")
                       end
            end

            def saveEC2_Instance_Types(path,it)
              format = getFileFormat(path)
              begin
                File.open path, File::CREAT|File::TRUNC|File::RDWR, 0644 do |f|
                  case format
                    when /yaml/
                      f.write it.to_yaml line_width: 1024, indentation: 4, canonical: false
                    when /json/
                      f.write JSON.pretty_generate(it, { indent: "\t", space: ' '})
                    else
                      abort! "Internal: Unsupported format #{format}. Should have noticed this earlier!"
                  end
                  f.close
                end
              rescue
                abort! "!!! Could not write file #{path}: \nException: #{$!}\nParent directory exists? #{File.directory?(File.dirname(path))}\n"
              end
              0
            end

            def loadEC2_Instance_Types(path)
              format = getFileFormat(path)
              spec = File.read(path)
              case format
                when /json/
                  JSON.parse(spec)
                when /yaml/
                  begin
                    YAML.load(spec)
                  rescue Psych::SyntaxError => e
                    abort! "Error in the template specification: #{e.message}\n#{spec.split(/\n/).map{|l| "#{i+=1}: #{l}"}.join("\n")}"
                  end
                else
                  abort! "Unsupported file type: #{path}"
              end
            end

            def getEC2_Instance_Types(mechanize=nil)
              unless mechanize
                require 'mechanize'
                mechanize = ::Mechanize.new
                mechanize.open_timeout = 5
                mechanize.read_timeout = 10
              end

              scraper = DLDInternet::AWS::EC2::Instance_Types::Scraper.new()

              begin
                return scraper.getInstanceTypes(:mechanize => mechanize)
              rescue Timeout::Error => e
                puts "Unable to retrieve instance type details in a reasonable time (#{mechanize.open_timeout}s). Giving up ...".light_red
                return nil
              end
            end

            def abort!(msg)
              raise DLDInternet::AWS::EC2::Instance_Types::Error.new msg
            end

          end
        end
      end
    end
  end
end