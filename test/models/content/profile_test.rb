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

  it "must be unique screen_name" do
    profile.screen_name = "_lalavalerie_"
    profile.must_be :invalid?

    profile.screen_name = "_lalavalerie_2"
    profile.must_be :valid?
  end

  it "must be numerical scores" do
    profile.screen_name = "test_screen_name"

    profile.raw_average_score = "non-numerical"
    profile.must_be :invalid?

    profile.raw_average_score = -1
    profile.must_be :valid?

    profile.raw_average_score = 0
    profile.must_be :valid?

    profile.raw_average_score = 128.88
    profile.must_be :valid?

    profile.weighted_score = "non-numerical"
    profile.must_be :invalid?

    profile.weighted_score = -1
    profile.must_be :valid?

    profile.weighted_score = 0
    profile.must_be :valid?

    profile.weighted_score = 128.88
    profile.must_be :valid?
  end
end
