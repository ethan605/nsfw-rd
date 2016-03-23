class CreateContentCompareRecords < ActiveRecord::Migration
  def change
    create_table :content_compare_records do |t|
      t.integer :compare_result
      t.belongs_to :first_image, null: false, index: true
      t.belongs_to :second_image, null: false, index: true

      t.timestamps null: false
    end
  end
end
