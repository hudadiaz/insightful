class CreateVisualizations < ActiveRecord::Migration
  def change
    create_table :visualizations do |t|
      t.references :datum, index: true, foreign_key: true
      t.string :title
      t.string :caption
      t.string :type,       null: false
      t.string :selections, null: false

      t.timestamps null: false
    end
  end
end
