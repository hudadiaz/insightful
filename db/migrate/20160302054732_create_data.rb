class CreateData < ActiveRecord::Migration
  def change
    create_table :data do |t|
      t.references :user, index: true, foreign_key: true
      t.string :name
      t.string :headers
      t.string :content
      t.string :ignored
      t.string :types
      
      t.timestamps null: false
    end
  end
end
