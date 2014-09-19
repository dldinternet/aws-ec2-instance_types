require 'thor'
require 'awesome_print'
require 'dldinternet/aws/ec2/instance_types/scraper'
require 'colorize'
require 'json'
require 'yaml'

module DLDInternet
  module AWS
    module EC2
      module Instance_Types
        # noinspection RubyParenthesesAfterMethodCallInspection
        class Get < ::Thor
          no_commands do

            require 'dldinternet/aws/ec2/instance_types/mixins/no_commands'
            include DLDInternet::AWS::EC2::Instance_Types::MixIns::NoCommands

          end

          desc 'load ARGS', 'load instance types'
          def load(path)
            parse_options
            puts 'load instance types' if options[:verbose]

            it = loadEC2_Instance_Types(path)
            ap it
          end

          desc 'save', 'save instance types'
          def save(path)
            parse_options
            puts 'save instance types' if options[:verbose]

            it = getEC2_Instance_Types()
            saveEC2_Instance_Types(path, it)
          end
        end
      end
    end
  end
end