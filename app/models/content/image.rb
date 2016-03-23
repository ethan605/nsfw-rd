class Content::Image < ActiveRecord::Base
  belongs_to :profile, class_name: "Content::Profile"
  has_many :compare_records, class_name: "Content::CompareRecord"

  validates_associated :profile, :compare_records

  validates :image_url, :presence => true, :uniqueness => true, :format => {:with => URI.regexp}
  validates_numericality_of :raw_average_score, :weighted_score
end