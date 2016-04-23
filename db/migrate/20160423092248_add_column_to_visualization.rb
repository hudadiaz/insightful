class AddColumnToVisualization < ActiveRecord::Migration
  def change
    add_column :visualizations, :datum_last_updated_at, :datetime, null: false, default: DateTime.now
  end
end
