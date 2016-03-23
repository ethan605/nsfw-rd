class Content::Profile < ActiveRecord::Base
  has_many :images, class_name: "Content::Image"

  validates_associated :images
  validates :screen_name, :presence => true, :uniqueness => true
  validates_numericality_of :raw_average_score, :weighted_score
end
