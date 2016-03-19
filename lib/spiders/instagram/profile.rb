class Spiders::Instagram::Profile
  attr_accessor :source
  attr_accessor :source_url
  attr_accessor :screen_name
  attr_accessor :display_name
  attr_accessor :images
  attr_reader :is_empty

  def initialize(args = {})
    profile = {             # default profile
      source: "",
      source_url: "",
      screen_name: "",
      display_name: "",
      images: []
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
  end

  def save_to_file(file_name = nil)
    file_name = Spiders::Instagram::Constants::FOLDER_NAME + "#{self.screen_name}-images.json" unless file_name

    json_hash = self.as_json
    json_hash.delete["is_empty"]
    File.write(file_name, JSON.pretty_generate(json_hash))
  end
end