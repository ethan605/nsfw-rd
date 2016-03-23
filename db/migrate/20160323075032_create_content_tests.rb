class CreateContentTests < ActiveRecord::Migration
  def change
    create_table :content_tests do |t|
      t.decimal :test_num

      t.timestamps null: false
    end
  end
end
