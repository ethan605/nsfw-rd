module Spiders
  class Logger
    attr_accessor :log

    def initialize(file_name = "#{Rails.root}/log/spiders/spider.log")
      @log = {}
      @file_name = file_name
      @start_time = Time.now

      Dir.mkdir("#{Rails.root}/log/spiders/") unless Dir.exists?("#{Rails.root}/log/spiders/")
    end

    def append_log(unique_id, message)
      @log[unique_id] ||= []
      @log[unique_id] << message
    end

    def write_file
      end_time = Time.now

      content = "\n\n" + "="*10 + "\n"
      content += "Start at: #{@start_time}\n"
      
      @log.each {|unique_id, messages|
        content += "\n[#{unique_id}]\n"
        messages.each { |message| content += "\t#{message}\n" }
      }
      
      content += "\nEnd at: #{Time.now} (#{end_time - @start_time}s)\n"
      content += "="*10

      File.open(@file_name, "a") {|f| f << content}
    end
  end
end