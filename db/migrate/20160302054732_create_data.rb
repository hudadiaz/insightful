class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name,    null: false
      t.string :headers, null: false
      t.text   :content, null: false
      t.string :ignored, default: "[]"
      t.string :numbers, default: "[]"
      
      t.timestamps null: false
    end
  end
end
