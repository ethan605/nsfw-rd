class Spiders::Utils
  def self.check_image_src(image_url)
    image_uri = URI(image_url)
    request = Net::HTTP.new image_uri.host
    response = request.request_head image_uri.path
    response.is_a? Net::HTTPSuccess
  end

  def self.select_not_found_images(image_urls)
    image_uri_hash = {}
    
    image_urls.each {|url|
      uri = URI(url)
      image_uri_hash[uri.scheme] ||= {}
      image_uri_hash[uri.scheme][uri.host] ||= []
      image_uri_hash[uri.scheme][uri.host] << uri.path
    }

    bad_urls = []

    image_uri_hash.each {|scheme, bodies|
      bodies.each {|host, paths|
        request = Net::HTTP.new host
        paths.each {|path|
          response = request.request_head path
          bad_urls << scheme + "://" + host + path unless response.is_a?(Net::HTTPSuccess)
        }
      }
    }

    bad_urls
  end
end