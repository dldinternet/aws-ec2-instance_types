module DLDInternet
  module AWS
    module EC2

      module Instance_Types
        DEBUG = true
        class AWSPricingAPIClient
          attr_reader :instance_types

          def initialize
            @instance_types = {}
          end

          # ---------------------------------------------------------------------------------------------------------------
          def get_instance_types(options={})
            unless @instance_types.size > 0
              require 'net/http'
              # url = options[:url] || 'https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/index.json'
              url = options[:url] || 'https://ec2instances.info/instances.json'

              uri = URI(url)
              # params = { :limit => 10, :page => 3 }
              # uri.query = URI.encode_www_form(params)

              while true
                response = Net::HTTP.get_response(uri)
                case response
                when Net::HTTPSuccess then
                  require 'json'
                  data = JSON.parse(response.body)
                  @instance_types = data
                  break
                when Net::HTTPRedirection then
                  uri = URI(response['location'])
                  # warn "redirected to #{location}"
                  # fetch(location, limit - 1)
                else
                  raise response.inspect
                end
              end
            end
            @instance_types
          end

        end
      end
    end
  end
end
