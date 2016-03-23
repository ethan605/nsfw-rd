class ContentModelsAddUnique < ActiveRecord::Migration
  def change
    change_column(:content_profiles, :screen_name, "string", :unique => true)
    change_column(:content_images, :image_url, "string", :unique => true)
  end
end
