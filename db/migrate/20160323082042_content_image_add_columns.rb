class ContentImageAddColumns < ActiveRecord::Migration
  def change
    change_table :content_images do |t|
      t.decimal :raw_average_score, default: 0
      t.decimal :weighted_score, default: 0
    end
  end
end
