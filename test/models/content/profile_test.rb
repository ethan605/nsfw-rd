require "test_helper"

describe Content::Profile do
  let(:profile) { Content::Profile.new }

  it "must be invalid as default" do
    value(profile).must_be :invalid?
  end

  it "must have zero scores by default" do
    profile.raw_average_score.must_equal 0
    profile.weighted_score.must_equal 0
  end
end
