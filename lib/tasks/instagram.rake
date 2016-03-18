require 'thwait'

namespace :spiders do
  namespace :instagram do
    task :grab_followings => :environment do
      Constants = Spiders::Constants::Instagram

      grabbing_number = ENV["articles"].present? ? ENV["articles"].to_i : 1
      grabbing_number = 1 if grabbing_number <= 0
      grabbing_number = Constants::MAX_GRABBING_NUMBER if grabbing_number > Constants::MAX_GRABBING_NUMBER

      concurrent_spiders = ENV["concurrent"].present? ? ENV["concurrent"].to_i : 1
      concurrent_spiders = 1 if concurrent_spiders <= 0
      concurrent_spiders = Constants::MAX_CONCURRENT_SPIDER if concurrent_spiders > Constants::MAX_CONCURRENT_SPIDER

      spider_threads = []
      mutex = Mutex.new
      logger = Spiders::Logger.new("instagram_spider.log")

      concurrent_spiders.times {|index|
        spider_thread = Thread.new {
          spider = Spiders::Instagram::InstSpider.new(mutex, logger)
          spider.grab_followings(grabbing_number)
          spider.end
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
  end
end
