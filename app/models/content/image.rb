class Content::Image < ActiveRecord::Base
  attr_accessor :image_url
  attr_accessor :raw_average_score
  attr_accessor :weighted_score

  belongs_to :profile, class_name: "Content::Profile"
  has_and_belongs_to_many :compare_records

  # validates_associated :profile, :compare_records
  # validates_presence_of :image_url
  validates :image_url, :presence => true, :format => {:with => URI.regexp}
  validates_numericality_of :raw_average_score, :weighted_score

  after_initialize :init_default_attributes

  def init_default_attributes
    self.raw_average_score = self['raw_average_score'].to_f
    self.weighted_score = self['weighted_score'].to_f
  end
end