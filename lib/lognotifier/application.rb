module Lognotifier

  class Application

    CONFIG_FILE = "/etc/lognotifier.yaml"
    @config = nil
    @logger = nil

    def initialize

      # Load configuration:
      begin
        @config = YAML::load(File.read CONFIG_FILE)
      rescue => e
        puts "Error at opening config file, error was:"
        puts e.message
        exit 1
      end

      # Initializa logger:
      @logger = Logger.new @config['logfile']

      # Main exec loop
      self.run
      
    end

    def run

      threads = []
      @config['pagerduty'].each do |conf|

        threads << Thread.new do

          # Variables:
          filename = conf[0]
          config = conf[1]

          # Initialize pager duty:
          pagerduty = Pagerduty.new(config['servicekey'])

          # Exit if file not exists

          begin
            file = File.open(filename)
          rescue => e
            @logger.error "ERROR OPENING FILE: #{filename}"
            @logger.error "ERROR WAS: #{e.message}"
            Thread.exit
          end
          file.seek(0,IO::SEEK_END)
          queue = INotify::Notifier.new  
          queue.watch(filename, :modify) do
            content = file.read
            config['patterns'].each do |pattern|
              if content.match(/#{pattern["regex"]}/)
                begin
                  pagerduty.trigger("#{pattern["prefix"]} #{content}")
                  @logger.info("ALERT TRIGGERD: #{pattern["prefix"]} #{content}" )
                rescue => e
                  @logger.error("FAILED TO SEND ALERT: #{pattern["prefix"]} #{content}" )
                  @logger.error("Error: #{e.message.to_s}" )
                end
              end
            end
          end
          queue.run 
        end
      end
      threads.each {|t| t.join}
    end
  end
end
