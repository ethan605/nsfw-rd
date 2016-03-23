require "test_helper"

describe Content::Image do
  let(:image) { Content::Image.new }

  it "must be invalid by default" do
    image.must_be :invalid?
  end

  it "must have zero scores by default" do
    image.raw_average_score.must_equal 0
    image.weighted_score.must_equal 0
  end

  it "must have unique & valid image_url" do
    image.image_url = "https://igcdn-photos-h-a.akamaihd.net/hphotos-ak-xat1/t51.2885-15/e35/12383245_1527953724174559_886986895_n.jpg"
    image.must_be :invalid?

    image.image_url = "test_malformed_url"
    image.must_be :invalid?

    # weird case
    # image.image_url = "htt://igcdn-photos-h-a.akamaihd.net/hphotos-ak-xat1/t51.2885-15/e35/12383245_1527953724174559_886986895_n.jpg"
    # image.must_be :valid?

    image.image_url = "https:/igcdn-photos-c-a.akamaihd.net/hphotos-ak-xaf1/t51.2885-15/e35/12822504_753817504752642_2129515794_n.jpg"
    image.must_be :valid?

    image.image_url = "https://igcdn-photos-c-a.akamaihd.net/hphotos-ak-xaf1/t51.2885-15/e35/12822504_753817504752642_2129515794_n.jpg"
    image.must_be :valid?
  end

  it "must have numerical scores" do
    image.image_url = "https://igcdn-photos-c-a.akamaihd.net/hphotos-ak-xaf1/t51.2885-15/e35/12822504_753817504752642_2129515794_n.jpg"

    {
      :invalid? => ["non-numerical"],
      :valid? => [-1, 0, 128.88]
    }.each {|state, scores|
      scores.each {|score|
        image.raw_average_score = score
        image.must_be state
      }
    }

    {
      :invalid? => ["non-numerical"],
      :valid? => [-1, 0, 128.88]
    }.each {|state, scores|
      scores.each {|score|
        image.weighted_score = score
        image.must_be state
      }
    }
  end
end
