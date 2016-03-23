require "test_helper"

describe Content::Profile do
  let(:profile) { Content::Profile.new }

  it "must be invalid as default" do
    profile.must_be :invalid?
  end

  it "must have zero scores by default" do
    profile.raw_average_score.must_equal 0
    profile.weighted_score.must_equal 0
  end

  it "must have unique screen_name" do
    profile.screen_name = "_lalavalerie_"
    profile.must_be :invalid?

    profile.screen_name = "_lalavalerie_2"
    profile.must_be :valid?
  end

  it "must have numerical scores" do
    profile.screen_name = "test_screen_name"

    {
      :invalid? => ["non-numerical"],
      :valid? => [-1, 0, 128.88]
    }.each {|state, scores|
      scores.each {|score|
        profile.raw_average_score = score
        profile.must_be state
      }
    }

    {
      :invalid? => ["non-numerical"],
      :valid? => [-1, 0, 128.88]
    }.each {|state, scores|
      scores.each {|score|
        profile.weighted_score = score
        profile.must_be state
      }
    }
  end
end
