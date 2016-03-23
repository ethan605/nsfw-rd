class ContentProfileChangeColumnDefault < ActiveRecord::Migration
  def change
    change_column_default(:content_profiles, :raw_average_score, 0)
    change_column_default(:content_profiles, :weighted_score, 0)
  end
end
