class AddViewsCounterCacheToVisualization < ActiveRecord::Migration
  def change
    add_column :visualizations, :views_counter_cache, :integer, default: 0
  end
end
