module Lognotifier

  class Application

    CONFIG_FILE = "/etc/lognotifier.yaml"
    LOG_FILE = "lognotifier.log"
    @config = nil
    @logger = nil

    def initialize

      # Initializa logger:
      @logger = Logger.new LOG_FILE

      # Load configuration:
      begin
        @config = YAML::load(File.read CONFIG_FILE)
      rescue => e
        puts "Error at opening config file, error was:"
        puts e.message
      end

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

          @logger.error "File not exists: #{filename}" if not File.exists? filename

          file = File.open(filename)
          file.seek(0,IO::SEEK_END)
          queue = INotify::Notifier.new  
          queue.watch(filename, :modify) do
            content = file.read
            pagerduty.trigger("#{config["message_prefix"]} #{content}") if content.match(/#{config["pattern"]}/)
          end
          queue.run 

        end

      end

      threads.each {|t| t.join}

    end

  end

end
