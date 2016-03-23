class ContentProfileImageAddNotNull < ActiveRecord::Migration
  def change
    change_column_null(:content_profiles, :screen_name, true)
    change_column_null(:content_images, :image_url, true)
  end
end
