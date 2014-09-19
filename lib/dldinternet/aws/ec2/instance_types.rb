module DLDInternet
  module AWS
    module EC2
      module Instance_Types

        class << self
          require 'dldinternet/aws/ec2/instance_types/mixins/ec2_instance_types'
          include DLDInternet::AWS::EC2::Instance_Types::MixIns::EC2_Instance_Types
        end

      end

    end

  end

end
