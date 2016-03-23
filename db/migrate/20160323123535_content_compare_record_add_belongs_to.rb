class ContentCompareRecordAddBelongsTo < ActiveRecord::Migration
  def change
    change_table :content_compare_records do |t|
      t.belongs_to :first_image, null: false, index: true
      t.belongs_to :second_image, null: false, index: true
    end

    change_column(:content_images, :profile_id, "integer", null: false)
  end
end
