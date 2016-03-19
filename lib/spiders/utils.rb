module Spiders
  class Utils
    def self.check_alive_image_url(image_url)
      image_uri = URI(image_url)
      request = Net::HTTP.new image_uri.host
      response = request.request_head image_uri.path
      response.is_a?(Net::HTTPSuccess)
    end

    def self.spot_bad_image_urls(image_urls)
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
            bad_urls << scheme + "://" + host + path unless response.code.to_i == 200
            puts (response.code.to_i == 200 ? " OK => " : "BAD => ") + host + path
          }
        }
      }

      bad_urls
    end
  end
end