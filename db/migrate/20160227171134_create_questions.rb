class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :question
      t.references :survey, index: true, foreign_key: true
      t.integer :type

      t.timestamps null: false
    end
  end
end
