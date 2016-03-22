module Spiders::Instagram::Constants
  DEFAULT_GATEWAY = "https://www.instagram.com"
  LOGIN_GATEWAY = "https://www.instagram.com/accounts/login/"

  FOLDER_NAME = Rails.root + "db/spiders/instagram/"
  FOLLOWINGS_FILE_NAME = FOLDER_NAME + "---following_urls---.txt"
  FOLLOWINGS_FILE_NAME_TEST = FOLDER_NAME + "---following_urls---.test.txt"

  LOG_FILE = Rails.root + "log/spiders/instagram.log"

  DEFAULT_GRAB_LIMIT = 100
  MAX_GRAB_LIMIT = 1000
  DEFAULT_CONCURRENT_SPIDERS = 3
  MAX_CONCURRENT_SPIDERS = 8
end