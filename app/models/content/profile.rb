class Content::Profile < ActiveRecord::Base
  attr_accessor :screen_name
  attr_accessor :raw_average_score
  attr_accessor :weighted_score

  has_many :images, class_name: "Content::Image"

  # validates_associated :images

  validates :screen_name, :presence => true, :uniqueness => true
  validates_numericality_of :raw_average_score, :weighted_score

  after_initialize :init_default_attributes

  def init_default_attributes
    self.raw_average_score = self['raw_average_score'].to_f
    self.weighted_score = self['weighted_score'].to_f
  end
end
