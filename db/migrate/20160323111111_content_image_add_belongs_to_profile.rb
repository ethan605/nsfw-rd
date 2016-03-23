class ContentImageAddBelongsToProfile < ActiveRecord::Migration
  def change
    change_table :content_images do |t|
      t.belongs_to :profile, index: true
    end
  end
end
