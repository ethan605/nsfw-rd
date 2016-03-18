require 'thwait'

namespace :spiders do
  namespace :instagram do
    def preprocess_args(grabbing_number_key, concurrent_spiders_key)
      grabbing_number = ENV[grabbing_number_key].present? ? ENV[grabbing_number_key].to_i : 1
      grabbing_number = 1 if grabbing_number <= 0
      grabbing_number = Constants::MAX_GRABBING_NUMBER if grabbing_number > Constants::MAX_GRABBING_NUMBER

      concurrent_spiders = ENV[concurrent_spiders_key].present? ? ENV[concurrent_spiders_key].to_i : 1
      concurrent_spiders = 1 if concurrent_spiders <= 0
      concurrent_spiders = Constants::MAX_CONCURRENT_SPIDER if concurrent_spiders > Constants::MAX_CONCURRENT_SPIDER

      [grabbing_number, concurrent_spiders]      
    end

    def parallel_grabbing(grabbing_number, concurrent_spiders)
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

    task :test => :environment do
    end

    task :grab_followings => :environment do
      Constants = Spiders::Instagram::Constants

      grabbing_number, concurrent_spiders = preprocess_args("articles", "concurrent")
      parallel_grabbing(grabbing_number, concurrent_spiders) do |spider, index|
        spider.grab_followings(grabbing_number)
      end
    end

    task :grab_followings_all_images => :environment do
      Constants = Spiders::Instagram::Constants

      grabbing_number, concurrent_spiders = preprocess_args("followings", "concurrent")
      concurrent_trunk_size = grabbing_number / concurrent_spiders +
                              (grabbing_number % concurrent_spiders == 0 ? 0 : 1)

      parallel_grabbing(grabbing_number, concurrent_spiders) do |spider, index|
        spider.grab_followings_all_images(
          grabbing_number,
          index * concurrent_trunk_size,
          concurrent_trunk_size
        )
      end
    end
  end
end
