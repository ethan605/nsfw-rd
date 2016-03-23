class Content::Image < ActiveRecord::Base
  belongs_to :profile, class_name: "Content::Profile"
  has_many :compare_record_as_firsts, class_name: "Content::CompareRecord", foreign_key: "first_image_id"
  has_many :compare_record_as_seconds, class_name: "Content::CompareRecord", foreign_key: "second_image_id"

  validates_associated :profile, :compare_record_as_firsts, :compare_record_as_seconds
  validates :image_url, :presence => true, :uniqueness => true, :format => {:with => URI.regexp}
  validates_numericality_of :raw_average_score, :weighted_score

  def compare_records
    Content::CompareRecord.where{(first_image_id == self.id) | (second_image_id == self.id)}
  end
end