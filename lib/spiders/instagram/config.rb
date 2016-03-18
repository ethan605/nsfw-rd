class Spiders::Instagram::Config
  include Singleton

  attr_accessor :client_id
  attr_accessor :client_secret
  attr_accessor :username
  attr_accessor :password

  def initialize
    yml_config_file = "#{Rails.root}/config/spiders_secrets.yml"
    yml_config = File.exists?(yml_config_file) ? YAML.load_file(yml_config_file) : {}
    yml_config = yml_config["instagram"].present? ? yml_config["instagram"] : {}
    
    @client_id = yml_config["client_id"]
    @client_secret = yml_config["client_secret"]
    @username = yml_config["username"]
    @password = yml_config["password"]
  end

  def self.configure
    yield(InstConfig.instance)
  end
end