module Spiders
  class Utils
    def self.check_alive_image_url(image_url, mechanize_agent = nil, benchmark = false)
      image_uri = URI(image_url)

      unless image_uri.is_a?(URI::HTTP) # malformed URI
        puts "MALFORMED => " + image_url
        return false
      end

      start_time = Time.now if benchmark

      unless mechanize_agent
        mechanize_agent = Mechanize.new
        mechanize_agent.user_agent_alias = 'Mac Firefox'
      end

      check_result = begin
        response = mechanize_agent.head(image_uri)
        response.is_a?(Mechanize::Image)
      rescue Mechanize::ResponseCodeError => e
        begin
          response = mechanize_agent.get(image_uri)
          response.is_a?(Mechanize::Image)
        rescue Mechanize::ResponseCodeError => e
          false
        end
      end

      benchmark_str = if benchmark
        "[%.3fs] " % (Time.now - start_time)
      else
        ""
      end

      puts benchmark_str + (check_result ? " OK => " : "BAD => ") + image_url
      check_result
    end

    def self.spot_bad_image_urls(image_urls)
      agent = Mechanize.new
      agent.user_agent_alias = 'Mac Firefox'
      image_urls.select { |image_url| !check_alive_image_url(image_url, nil, true) }
    end

    def self.parallel_processing(concurrent_threads, log_file)
      threads = []
      mutex = Mutex.new
      logger = Spiders::Logger.new(log_file)

      concurrent_threads.times {|index|
        thread = Thread.new { yield(index, mutex, logger) }
        puts "[*] Created new thread #{thread}\n"
        threads << thread
      }

      threads.each(&:join)          # join all threads to main thread for exceptions handling
      ThreadsWait.all_waits(*threads) { |thread| puts "[*] Thread #{thread} done\n" }

      logger.write_file
    end
  end
end