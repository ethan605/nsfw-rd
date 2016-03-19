require 'thwait'

class Spiders::Instagram::Profile
  attr_accessor :source
  attr_accessor :source_url
  attr_accessor :screen_name
  attr_accessor :display_name
  attr_accessor :images
  attr_accessor :bad_images
  attr_reader :is_empty

  def initialize(args = {})
    profile = {             # default profile
      source: "",
      source_url: "",
      screen_name: "",
      display_name: "",
      images: [],
      bad_images: []
    }
    
    profile = args[:hash_profile] if args[:hash_profile] && args[:hash_profile].is_a?(Hash)

    if args[:screen_name] || args[:file_name]
      json_file = Spiders::Instagram::Constants::FOLDER_NAME + "#{args[:screen_name]}-images.json" if args[:screen_name]
      json_file = args[:file_name] if args[:file_name]
      profile = JSON.parse(File.read(json_file)) if File.exists?(json_file)
    end

    if profile.nil? || profile.empty?
      raise ArgumentError, "invalid argument: must be either a valid hash_profile, screen_name or file_name"
    end

    profile.each {|key, value| send(key.to_s + "=", value)}

    @is_empty = @source_url.empty? || @screen_name.empty? || @images.empty?
    @bad_images ||= []
  end

  def save_to_file(file_name = nil)
    file_name = Spiders::Instagram::Constants::FOLDER_NAME + "#{self.screen_name}-images.json" unless file_name

    json_hash = self.as_json
    json_hash.delete("is_empty")
    json_hash.delete("bad_images")
    File.write(file_name, JSON.pretty_generate(json_hash))
  end

  def spot_bad_images(concurrent_threads = 3)
    threads = []
    alive_urls = (self.images + self.bad_images).dup
    final_bad_urls = alive_urls.dup
    mutex = Mutex.new

    concurrent_threads.times {|index|
      thread = Thread.new {
        bad_urls = Spiders::Utils.spot_bad_image_urls(alive_urls.shuffle)
        mutex.synchronize { final_bad_urls &= bad_urls }
      }

      puts "[*] Create new thread #{thread}\n"
      threads << thread
    }

    threads.each(&:join)

    ThreadsWait.all_waits(*threads) do |thread|
      puts "[*] Thread #{thread} done!"
    end

    self.bad_images = final_bad_urls
    self.images -= self.bad_images

    self.bad_images
  end
end