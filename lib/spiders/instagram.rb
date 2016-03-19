class Spiders::Instagram
  attr_reader :browser
  attr_reader :current_profile
  attr_accessor :write_mutex
  attr_accessor :logger

  def initialize(write_mutex = nil, logger = nil)
    @browser = Watir::Browser.start Constants::LOGIN_GATEWAY
    @write_mutex = write_mutex
    @logger = logger

    @browser.text_field(:name => "username").when_present.set(Config.instance.username)
    @browser.text_field(:name => "password").when_present.set(Config.instance.password)
    @browser.button(:text => "Log in").when_present.click

    Watir::Wait.until { @browser.title == "Instagram" }
  end

  def echo_output(message, indent_level = 0, completion_rate = -1, benchmark_start_time = -1)
    self_address = "[#{hex_address}] "
    indent = "\s\s" * indent_level

    completion_rate = if completion_rate > 0
      "[%02d%%] " % (completion_rate * 100)
    else
      ""
    end

    benchmark = if benchmark_start_time.to_i > 0
      " [%.2fms]" % ((Time.now - benchmark_start_time) * 1000)
    else
      ""
    end

    @logger.append_log(hex_address, completion_rate + message + benchmark) if @logger
    puts indent + self_address + completion_rate + message + benchmark
  end

  def grab_followings(max_articles = Constants::DEFAULT_GRAB_LIMIT)
    echo_output("Grabbing news feed articles")

    @browser.goto Constants::DEFAULT_GATEWAY
    articles_count = @browser.articles.count
    echo_output("Grabbed #{articles_count} articles", 1)

    @browser.a(text: "Load more").click

    start_time = Time.now

    while articles_count < max_articles
      begin
        @browser.scroll.to :bottom
        Watir::Wait.until { articles_count < @browser.articles.count }
      rescue Watir::Wait::TimeoutError => e
        break
      end

      articles_count = @browser.articles.count
      echo_output("Grabbed #{articles_count} articles", 1, -1, start_time)
    end

    @browser.scroll.to :top

    following_urls = @browser.articles.map {|article| article.header.a.href}.uniq

    if @write
      @write_mutex.synchronize { write_following_urls_to_file(following_urls) }
    else
      write_following_urls_to_file(following_urls)
    end
  end

  def grab_followings_all_images(
        max_followings = Constants::DEFAULT_GRAB_LIMIT,
        offset = 0,
        size = Constants::DEFAULT_GRAB_LIMIT
      )
    following_urls = read_following_urls_from_file.first(max_followings)[offset, size]

    return unless following_urls

    following_urls.each {|following_url|
      profile_screen_name = following_url.sub(/https:\/\/www.instagram.com\//, '').sub(/\//, '')
      posts_count = get_following_posts_count(profile_screen_name)
      existed_profile = Profile.new(profile_screen_name)
      # existed_profile = read_following_all_images_from_file(profile_screen_name)

      grab_one_following_images(following_url, posts_count, existed_profile)
    }
  end

  def grab_one_following_images(following_url, posts_count, existed_profile)
    @browser.goto(following_url)

    profile = Profile.new(hash_profile: {
      source: "instagram",
      source_url: "https://www.instagram.com",
      screen_name: @browser.h1.present? ? @browser.h1.text : "<blank>",
      display_name: @browser.h2.present? ? @browser.h2.text : "<blank>",
      images: normalize_images_urls(@browser.images)
    })

    puts "\n"
    echo_output("Grabbing #{posts_count} images for #{profile.screen_name}")
    echo_output(
      "[#{profile.screen_name}] Grabbed #{profile.images.count} images",
      1,
      profile.images.count.to_f / posts_count
    )

    while @browser.a(:text => "Load more").present?
      if (existed_profile.images & profile.images).count > 0
        echo_output("Nothing new with #{profile.screen_name}, move on!", 1)
        break
      end

      start_time = Time.now

      next_page = @browser.a(:text => "Load more").href
      @browser.goto(next_page)
      profile.images |= normalize_images_urls(@browser.images)

      grabbed_count = profile.images.count
      echo_output(
        "[#{profile.screen_name}] Grabbed #{grabbed_count} images",
        1,
        grabbed_count.to_f / posts_count, start_time
      )
    end

    profile.images |= existed_profile.images
    profile.images.uniq!

    if @write_mutex
      @write_mutex.synchronize { profile.save_to_file }
    else
      profile.save_to_file
    end
  end

  def finalize
    @browser.close
  end

  private
  def hex_address
    "0x00%x" % (object_id * 2)
  end

  def normalize_images_urls(images)
    urls = images.map(&:src)
    urls.shift                # remove avatar image
    urls.map {|s| s.sub(/\?ig_cache_key=.*/, '')}
  end

  def prepare_data_folder
    Dir.mkdir(Constants::FOLDER_NAME) unless Dir.exists?(Constants::FOLDER_NAME)
  end

  def write_following_urls_to_file(following_urls)
    prepare_data_folder

    file_name = Constants::FOLLOWINGS_FILE_NAME
    File.write(file_name, "") unless File.exists?(file_name)
    
    following_urls |= File.read(file_name).split("\n")
    File.write(file_name, following_urls.uniq.sort.join("\n"))
  end

  def read_following_urls_from_file
    file_name = Constants::FOLLOWINGS_FILE_NAME
    return [] unless File.exists?(file_name)

    File.read(file_name).split("\n")
  end

  def get_following_posts_count(profile_screen_name)
    @browser.goto(Constants::DEFAULT_GATEWAY + "/" + profile_screen_name)
    posts_count_label = @browser.elements(css: "article header div ul li > span").first
    
    posts_count_label.present? ? posts_count_label.text.sub(/\s+|,|post(s)*/, '').to_i : 0
  end

  # def write_following_all_images_to_file(profile)
  #   prepare_data_folder
  #   file_name = Constants::FOLDER_NAME + "#{profile[:screen_name]}-images.json"

  #   File.write(file_name, JSON.pretty_generate(profile))
  # end

  # def read_following_all_images_from_file(profile_screen_name)
  #   file_name = Constants::FOLDER_NAME + "#{profile_screen_name}-images.json"
  #   return {} unless File.exists?(file_name)

  #   JSON.parse(File.read(file_name))
  # end
end