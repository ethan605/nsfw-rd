require "test_helper"

describe Content::CompareRecord do
  let(:compare_record) { Content::CompareRecord.new }

  it "must be invalid by default" do
    value(compare_record).must_be :invalid?
  end
end
