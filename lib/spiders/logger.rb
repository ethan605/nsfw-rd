class Spiders::Logger
  attr_accessor :log

  def initialize(file_name = "#{Rails.root}/log/spiders/spider.log")
    @log = {}
    @file_name = file_name

    Dir.mkdir("#{Rails.root}/log/spiders/") unless Dir.exists?("#{Rails.root}/log/spiders/")
  end

  def append_log(unique_id, message)
    @log[unique_id] ||= []
    @log[unique_id] << message
  end

  def write_file
    content = "\n\n" + "="*10 + "\n"
    content += "Timestamp: #{Time.now}\n"
    @log.each {|unique_id, messages|
      content += "\n[#{unique_id}]\n"
      messages.each { |message| content += "\t#{message}\n" }
    }
    content += "\n" + "="*10

    File.open(@file_name, "a") {|f| f << content}
  end
end