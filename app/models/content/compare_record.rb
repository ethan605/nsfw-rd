class Content::CompareRecord < ActiveRecord::Base
  attr_accessor :compare_result

  has_one :first_image, class_name: "Content::Image"
  has_one :second_image, class_name: "Content::Image"

  # validates_associated :first_image, :second_image
  
  validates_inclusion_of :compare_result, :in => [-1, 1]
  validate :images_must_be_different

  def images_must_be_different
    return if first_image_id == second_image_id

    errors.add(:second_image_id, "must be different from first_image_id")
  end
end
