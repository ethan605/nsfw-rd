class CreateContentCompareRecords < ActiveRecord::Migration
  def change
    create_table :content_compare_records do |t|
      t.integer :compare_result

      t.timestamps null: false
    end
  end
end
