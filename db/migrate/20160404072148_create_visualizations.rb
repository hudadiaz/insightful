class CreateVisualizations < ActiveRecord::Migration
  def change
    create_table :visualizations do |t|
      t.string :title
      t.string :caption
      t.string :type
      t.string :selections
      t.references :datum, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
