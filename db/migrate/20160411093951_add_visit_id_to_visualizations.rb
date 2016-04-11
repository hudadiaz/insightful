class AddVisitIdToVisualizations < ActiveRecord::Migration
  def change
    add_column :visualizations, :visit_id, :integer
  end
end
