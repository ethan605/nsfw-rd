class Spiders::Instagram::Profile
  attr_accessor :source
  attr_accessor :source_url
  attr_accessor :screen_name
  attr_accessor :display_name
  attr_accessor :images

  def initialize(args = {})
    profile = nil
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
  end

  def save_to_file(file_name = nil)
    file_name = Spiders::Instagram::Constants::FOLDER_NAME + "#{self.screen_name}-images.test.json" unless file_name
    File.write(file_name, JSON.pretty_generate(self.as_json))
  end
end