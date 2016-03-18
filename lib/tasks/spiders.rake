def process_by_args
  if ARGV.count != 1 && ARGV.count != 2 && ARGV.count != 3
    echo_usage
    return
  end

  unless %w[--grab-followings --grab-followings-images].include?(ARGV.first)
    echo_usage
    return
  end

  grabbing_number = ARGV.count < 2 ? DEFAULT_GRABBING_NUMBER : ARGV[1].to_i
  grabbing_number = 1 if grabbing_number <= 0
  grabbing_number = MAX_GRABBING_NUMBER if grabbing_number > MAX_GRABBING_NUMBER

  concurrent_spiders = ARGV.count < 3 ? 1 : ARGV[2].to_i
  concurrent_spiders = 1 if concurrent_spiders <= 0
  concurrent_spiders = MAX_CONCURRENT_SPIDER if concurrent_spiders > MAX_CONCURRENT_SPIDER
  concurrent_trunk_size = grabbing_number / concurrent_spiders + (grabbing_number % concurrent_spiders == 0 ? 0 : 1)

  spider_threads = []
  mutex = Mutex.new
  logger = SpiderLogger.new("instagram_spider.log")

  concurrent_spiders.times {|index|
    spider_thread = Thread.new {
      spider = InstSpider.new(mutex, logger)
      spider.browser.goto "https://google.com"

      if ARGV.first == "--grab-followings"
        spider.grab_followings(grabbing_number)
      elsif ARGV.first == "--grab-followings-images"
        spider.grab_followings_all_images(
          grabbing_number,
          index * concurrent_trunk_size,
          concurrent_trunk_size
        )
      end

      spider.browser.close
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

def echo_usage
  puts "Instagram spider v1.0"
  puts "Usage:\n\n"
  
  puts "\tTo grab user's all following profiles (by scrap news feed articles):"
  puts "\t\truby instagram_spider.rb --grab-followings " +
       "[max news feed article (default = #{DEFAULT_GRABBING_NUMBER}, max = #{MAX_GRABBING_NUMBER})] " +
       "[concurrent spider (default = 1, max = #{MAX_CONCURRENT_SPIDER})]\n\n"

  puts "\tTo grab all followings' images:"
  puts "\t\truby instagram_spider.rb --grab-followings-images " +
       "[max followings in file (default = #{DEFAULT_GRABBING_NUMBER}, max = #{MAX_GRABBING_NUMBER})] " +
       "[concurrent spider (default = 1, max = #{MAX_CONCURRENT_SPIDER})]\n\n"
end

def test
  urls = %w[
    https://www.instagram.com/5mpixels/
    https://www.instagram.com/7wonder_woman/
    https://www.instagram.com/_bizomp__omg/
  ]
  
  spider_threads = []
  logger = SpiderLogger.new("instagram_spider.log")

  urls.each {|url|
    spider_thread = Thread.new {|t|
      spider = InstSpider.new(nil, logger)
      logger.append_log(spider.hex_address, url)
      spider.browser.goto url
      spider.browser.close
    }

    spider_threads << spider_thread
    puts "Created new thread #{spider_thread}"
  }

  spider_threads.each(&:join)

  ThreadsWait.all_waits(*spider_threads) do |thread|
    puts "Thread #{thread} done\n"
  end

  logger.write_file
end

# process_by_args
# test