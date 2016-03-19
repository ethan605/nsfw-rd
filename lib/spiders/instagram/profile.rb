class Spiders::Instagram::Profile
  attr_accessor :source
  attr_accessor :source_url
  attr_accessor :screen_name
  attr_accessor :display_name
  attr_accessor :images

  def initialize(args = {})
    hash_profile = {}
    hash_profile = args["hash_profile"] if args["hash_profile"] && args["hash_profile"].is_a?(Hash)
    hash_profile = JSON.parse(File.read(args["json_profile"])) if args["json_profile"] && File.exists?(args["json_profile"])

    hash_profile.each {|key, value| send(key + "=", value)}
  end
end