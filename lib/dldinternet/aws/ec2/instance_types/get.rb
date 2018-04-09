require 'thor'
require 'awesome_print'
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

            it = load_ec2_instance_types(path)
            ap it
          end

          desc 'save', 'save instance types'
          def save(path)
            parse_options
            puts 'save instance types' if options[:verbose]

            it = get_ec2_instance_types()
            save_ec2_instance_types(path, it)
          end
        end
      end
    end
  end
end