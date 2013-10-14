module DLDInternet
  module AWS
    module EC2
      HEADINGS = [
          :instance_family,         # [0]
          :instance_type,           # [1]
          :processor_arch,          # [2]
          :vCPU,                    # [3]
          :ECU,                     # [4]
          :memory,                  # [5]
          :instance_storage,        # [6]
          :EBS_optimized_available, # [7]
          :network_performance      # [8]
      ]

      attr_reader :instance_types

      def getInstanceTypes(options={})
        unless @instance_types
          @instance_types = {}
          require "mechanize"
          mechanize = options[:mechanize]
          unless mechanize
            mechanize = Mechanize.new
            mechanize.user_agent_alias = 'Mac Safari' # Pretend to use a Mac
          end
          url = options[:url] || 'http://aws.amazon.com/ec2/instance-types/instance-details/'

          page = mechanize.get(url)

          require "nokogiri"
          nk = Nokogiri::HTML(page.body)
          table = nk.css("div#yui-main div.yui-b table")
          raise AWSEC2Error.new "Cannot find instance type table" unless table.is_a?(Nokogiri::XML::NodeSet)
          rows = table.search('tr')[0..-1]
          head = rows.shift

          cols = head.search('td').collect { |td|
            text = td.text.to_s
            text = text.gsub(%r/(\r?\n)+/, ' ').strip
            CGI.unescapeHTML(text)
          }

          @instance_types[:headings] = {}
          (0..cols.size-1).map{|i| @instance_types[:headings][HEADINGS[i]] = cols[i] }

          @instance_types[:details] = []
          rows.each do |row|

            cells = row.search('td').collect { |td|
              CGI.unescapeHTML(td.text.to_s.gsub(%r/(\r?\n)+/, ' ').strip.gsub('32-bit or64-bit', '32-bit or 64-bit'))
            }
            raise StandardError.new "This row does not have the same number of cells as the table header: #{row.text.to_s.strip}" unless cells.size == cols.size
            instance = {}
            (0..cells.size-1).map{|i| instance[HEADINGS[i]] = cells[i] }
            @instance_types[:details] << instance

          end
        end
        @instance_types
      end
    end
  end
end