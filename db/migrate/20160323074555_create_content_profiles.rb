class CreateContentProfiles < ActiveRecord::Migration
  def change
    create_table :content_profiles do |t|
      t.string :screen_name, null: false
      t.decimal :raw_average_score, default: 0
      t.decimal :weighted_score, default: 0

      t.timestamps null: false
    end
  end
end
