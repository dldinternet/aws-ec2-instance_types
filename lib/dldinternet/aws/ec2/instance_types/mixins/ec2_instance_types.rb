require 'thor'
require 'awesome_print'
require 'inifile'
require 'colorize'
require 'dldinternet/aws/ec2/instance_types/aws-pricing-api-client'

module DLDInternet
  module AWS
    module EC2
      module Instance_Types
        module MixIns
          module EC2_Instance_Types

            def get_file_format(path)
              format = case File.extname(File.basename(path)).downcase
                         when /json|js/
                           'json'
                         when /yaml|yml/
                           'yaml'
                         else
                           raise DLDInternet::AWS::EC2::Instance_Types::Error.new("Unsupported file type: #{path}")
                       end
            end

            def save_ec2_instance_types(path, it)
              format = get_file_format(path)
              begin
                File.open path, File::CREAT|File::TRUNC|File::RDWR, 0644 do |f|
                  case format
                    when /yaml/
                      f.write it.to_yaml line_width: 1024, indentation: 4, canonical: false
                    when /json/
                      f.write JSON.pretty_generate(it, { indent: "\t", space: ' '})
                    else
                      f.write YAML::dump(it)
                      # abort! "Unsupported save format #{format}!"
                  end
                  f.close
                end
              rescue
                abort! "!!! Could not write file #{path}: \nException: #{$!}\nParent directory exists? #{File.directory?(File.dirname(path))}\n"
              end
              0
            end

            def load_ec2_instance_types(path)
              format = get_file_format(path)
              spec = File.read(path)
              case format
                when /json/
                  JSON.parse(spec)
                #when /yaml/
                else
                  begin
                    YAML.load(spec)
                  rescue Psych::SyntaxError => e
                    abort! "Error in the template specification: #{e.message}\n#{spec.split(/\n/).map{|l| "#{i+=1}: #{l}"}.join("\n")}"
                  end
                # else
                #   abort! "Unsupported file type: #{path}"
              end
            end

            # noinspection RubyDefParenthesesInspection
            def get_ec2_instance_types()

              client = DLDInternet::AWS::EC2::Instance_Types::AWSPricingAPIClient.new()

              begin
                # noinspection RubyParenthesesAfterMethodCallInspection
                return client.get_instance_types()
              rescue Exception => e
                puts "Unable to retrieve instance type details. Giving up ...".light_red
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