require 'thwait'

namespace :spiders do
  namespace :instagram do
    task :test => :environment do
    end

    task :grab_followings => :environment do
      Constants = Spiders::Instagram::Constants

      grab_limit, concurrent_spiders = preprocess_args("limit", "concurrent")
      parallel_grabbing(grab_limit, concurrent_spiders) do |spider, index|
        spider.grab_followings(grab_limit)
      end
    end

    task :grab_followings_all_images => :environment do
      Constants = Spiders::Instagram::Constants

      grab_limit, concurrent_spiders = preprocess_args("limit", "concurrent")
      concurrent_trunk_size = grab_limit / concurrent_spiders +
                              (grab_limit % concurrent_spiders == 0 ? 0 : 1)

      parallel_grabbing(grab_limit, concurrent_spiders) do |spider, index|
        spider.grab_followings_all_images(
          grab_limit,
          index * concurrent_trunk_size,
          concurrent_trunk_size
        )
      end
    end

    task :clean_up_all_followings_images => :environment do
      Constants = Spiders::Instagram::Constants

      Dir[Constants::FOLDER_NAME + "*.json"].each {|json_file|
        clean_up_following_images_file(json_file)
      }
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

    def parallel_grabbing(grab_limit, concurrent_spiders)
      spider_threads = []
      mutex = Mutex.new
      logger = Spiders::Logger.new(Constants::LOG_FILE)

      concurrent_spiders.times {|index|
        spider_thread = Thread.new {
          spider = Spiders::Instagram.new(mutex, logger)
          yield(spider, index)
          spider.finalize
        }

        spider_threads << spider_thread
        puts "[*] Created new thread #{spider_thread}\n"
      }

      spider_threads.each(&:join)

      ThreadsWait.all_waits(*spider_threads) do |thread|
        puts "Thread #{thread} done\n"
      end

      logger.write_file
    end

    def clean_up_following_images_file(json_file)
    end
  end
end
