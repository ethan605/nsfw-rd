module Spiders::Instagram::Constants
  DEFAULT_GATEWAY = "https://www.instagram.com"
  LOGIN_GATEWAY = "https://www.instagram.com/accounts/login/"

  FOLDER_NAME = Rails.root + "db/spiders/instagram/"
  # FOLLOWINGS_FILE_NAME = FOLDER_NAME + "---following_urls---.txt"
  FOLLOWINGS_FILE_NAME = FOLDER_NAME + "---following_urls---.test.txt"

  LOG_FILE = Rails.root + "log/spiders/instagram.log"

  DEFAULT_GRABBING_NUMBER = 100
  MAX_GRABBING_NUMBER = 1000
  DEFAULT_CONCURRENT_SPIDER = 1
  MAX_CONCURRENT_SPIDER = 8
end