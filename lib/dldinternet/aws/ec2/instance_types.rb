module DLDInternet
  module AWS
    module EC2
      class Error < StandardError ; end
      # HEADINGS = [
      #     :instance_family,         # [0]
      #     :instance_type,           # [1]
      #     :processor_arch,          # [2]
      #     :vCPU,                    # [3]
      #     :ECU,                     # [4]
      #     :memory,                  # [5]
      #     :instance_storage,        # [6]
      #     :EBS_optimized_available, # [7]
      #     :network_performance      # [8]
      # ]
      #'Instance Type','vCPU','Memory (GiB)',' Storage (GB)','Networking Performance','Physical Processor','Clock Speed (GHz)','Intel® AES-NI','Intel® AVX†','Intel® Turbo','EBS OPT','Enhanced Networking'
      HEADINGS_CPU = [
          :instance_type,				    # [0]
          :vCPU,                    # [1]
          :memory,                  # [2]
          :instance_storage,        # [3]
          :networking_performance,	# [4]
          :physical_processor,	    # [5]
          :clock_speed,       	    # [6]
          :Intel_AES_NI,				    # [7]
          :Intel_AVX,						    # [8]
          :Intel_Turbo,					    # [9]
          :EBS_OPT,                 # [10]
          :enhanced_networking      # [11]
      ]
      DEBUG = true
      attr_reader :instance_types

      # ---------------------------------------------------------------------------------------------------------------
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

          require 'nokogiri'

          nk = Nokogiri::HTML(page.body)
          # noinspection RubyAssignmentExpressionInConditionalInspection
          if div = find_div(nk, %r'^<div\s+class="nine columns content-with-nav')
            # noinspection RubyAssignmentExpressionInConditionalInspection
            if div = find_div(div, %r'^<div\s+class="content parsys')
              divs = div.css('div').to_a
              itm = nil
              idx = 0
              divs.each do |d|
                as = d.css('div div h2 a')
                as.each do |a|
                  # puts "'#{a.text}'"
                  if a.text == ' Instance Types Matrix '
                    itm = d
                    break
                  end
                end
                break if itm
                idx += 1
              end
              itm = divs[idx+1+2]
              table = itm.css('div table').first
              # puts "#{idx}: #{table.to_s}"
              @instance_types = scrapeTable(HEADINGS_CPU, table)
            end
          end
        end
        @instance_types
      end

      def find_div(nk,regex)
        ret = nil
        divs = nk.search('div')
        if divs.count > 0
          nine = divs.select { |div| div.to_s.match regex }
          if nine.count == 1
            nine = nine.shift
            ret = nine
          end
        end
        ret
      end

      # ---------------------------------------------------------------------------------------------------------------
      def scrapeTable(cHeadings,table)
        raise Error.new 'Cannot find instance type table' unless table.is_a?(Nokogiri::XML::Element)
        rows = table.search('tr')[0..-1]
        head = rows.shift

        cols = head.search('td').collect { |td|
          text = td.text.to_s
          text = text.gsub(%r/(\r?\n)+/, ' ').strip
          CGI.unescapeHTML(text)
        }
        instance_types = {
            :headings => {},
            :details  => []
        }
        (0..cols.size-1).map { |i| instance_types[:headings][cHeadings[i]] = cols[i] }

        rows.each do |row|

          cells = row.search('td').collect { |td|
            CGI.unescapeHTML(td.text.to_s.gsub(%r/(\r?\n)+/, ' ').strip.gsub('32-bit or64-bit', '32-bit or 64-bit'))
          }
          raise StandardError.new "This row does not have the same number of cells as the table header: #{row.text.to_s.strip}" unless cells.size == cols.size
          instance = {}
          (0..cells.size-1).map { |i| instance[cHeadings[i]] = cells[i] }
          instance_types[:details] << instance
        end
        instance_types
      end
    end
  end
end