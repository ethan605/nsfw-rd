class CreateContentImages < ActiveRecord::Migration
  def change
    create_table :content_images do |t|
      t.string :image_url, null: false, unique: true
      t.decimal :raw_average_score, default: 0
      t.decimal :weighted_score, default: 0

      t.timestamps null: false
    end
  end
end
