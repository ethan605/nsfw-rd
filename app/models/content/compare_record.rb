class Content::CompareRecord < ActiveRecord::Base
  belongs_to :first_image, class_name: "Content::Image"
  belongs_to :second_image, class_name: "Content::Image"

  validates_presence_of :first_image, :second_image
  validates_inclusion_of :compare_result, :in => [-1, 1]
  validate :images_must_be_different

  def images_must_be_different
    return if first_image_id == second_image_id

    errors.add(:second_image_id, "must be different from first_image_id")
  end
end
