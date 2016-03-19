namespace :spiders do
  namespace :instagram do
    task :test => :environment do
    end

    task :grab_followings => :environment do
      Constants = Spiders::Instagram::Constants

      grab_limit, concurrent_spiders = preprocess_args("limit", "concurrent")
      Spiders::Utils.parallel_processing(concurrent_spiders, Constants::LOG_FILE) do |index, mutex, logger|
        spider = Spiders::Instagram.new(mutex, logger)
        spider.grab_followings(grab_limit)
        spider.finalize
      end
    end

    task :grab_followings_all_images => :environment do
      Constants = Spiders::Instagram::Constants

      grab_limit, concurrent_spiders = preprocess_args("limit", "concurrent")
      concurrent_trunk_size = grab_limit / concurrent_spiders +
                              (grab_limit % concurrent_spiders == 0 ? 0 : 1)

      Spiders::Utils.parallel_processing(concurrent_spiders, Constants::LOG_FILE) do |index, mutex, logger|
        spider = Spiders::Instagram.new(mutex, logger)
        spider.grab_followings_all_images(
          grab_limit,
          index * concurrent_trunk_size,
          concurrent_trunk_size
        )
        spider.finalize
      end
    end

    task :clean_up_all_followings_images => :environment do
      Constants = Spiders::Instagram::Constants
      Profile = Spiders::Instagram::Profile

      grab_limit, concurrent_threads = preprocess_args("limit", "concurrent")
      concurrent_trunk_size = grab_limit / concurrent_threads +
                              (grab_limit % concurrent_threads == 0 ? 0 : 1)

      following_urls = File.read(Constants::FOLLOWINGS_FILE_NAME).split("\n")

      bad_images = {}

      Spiders::Utils.parallel_processing(concurrent_threads, Constants::LOG_FILE) do |index, mutex, logger|
        trunked_followings = following_urls[index * concurrent_trunk_size, concurrent_trunk_size] || []

        trunked_followings.each {|following_url|
          profile_screen_name = following_url.sub(/https:\/\/www.instagram.com\//, '').sub(/\//, '')
          profile = Profile.new(screen_name: profile_screen_name)
          profile.spot_bad_images(concurrent_threads)

          mutex.synchronize { bad_images[profile.screen_name] = profile.bad_images }
        }
      end

      bad_images.delete_if {|screen_name, images| images.empty?}
      file_name = Constants::FOLDER_NAME + "---bad_images---.json"
      File.write(file_name, JSON.pretty_generate(bad_images))
    end

    def preprocess_args(grab_limit_key, concurrent_spiders_key)
      grab_limit = ENV[grab_limit_key].present? ? ENV[grab_limit_key].to_i : 1
      grab_limit = Constants::DEFAULT_GRAB_LIMIT if grab_limit <= 0
      grab_limit = Constants::MAX_GRAB_LIMIT if grab_limit > Constants::MAX_GRAB_LIMIT

      concurrent_spiders = ENV[concurrent_spiders_key].present? ? ENV[concurrent_spiders_key].to_i : 1
      concurrent_spiders = Constants::DEFAULT_CONCURRENT_SPIDERS if concurrent_spiders <= 0
      concurrent_spiders = Constants::MAX_CONCURRENT_SPIDERS if concurrent_spiders > Constants::MAX_CONCURRENT_SPIDERS

      [grab_limit, concurrent_spiders]      
    end
  end
end
