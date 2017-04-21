module Lognotifier
  class Application
    CONFIG_FILE = '/etc/lognotifier.yaml'
    @config = nil
    @logger = nil

    def initialize
      # Load configuration:
      begin
        @config = YAML.load(File.read CONFIG_FILE)
      rescue => e
        puts 'Error at opening config file, error was:'
        puts e.message
        exit 1
      end

      # Initializa logger:
      @logger = Logger.new @config['logfile']

      # Main exec loop
      run
    end

    def run
      @logger.info 'Starting lognotifierd'

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
            @logger.info "Opening file #{filename} for log pattern search"
          rescue => e
            @logger.error "ERROR OPENING FILE: #{filename}"
            @logger.error "ERROR WAS: #{e.message}"
            Thread.exit
          end

          # Seek to the end of the file and watch for changes
          file.seek(0, IO::SEEK_END)
          queue = INotify::Notifier.new

          # previous to nil to record the previous line
          previous = nil

          # Watch for modified actions, read the content and alert if match
          # When alerting also send the previous line if available
          queue.watch(filename, :modify) do
            content = file.read
            config['patterns'].each do |pattern|
              next unless content.match(/#{pattern["regex"]}/)
              message = ''
              message += previous.chomp + ' | ' unless previous.nil? || previous == content
              message += content.chomp
              begin
                pagerduty.trigger("#{pattern['prefix']}", {'details' => message})
                @logger.info("ALERT TRIGGERD - #{pattern['prefix']}: #{message}")
              rescue => e
                @logger.error("FAILED TO SEND ALERT: #{pattern['prefix']} #{message}")
                @logger.error("Error: #{e.message}")
              end
            end
            previous = content
          end
          queue.run
        end
      end
      threads.each(&:join)
    end
  end
end
