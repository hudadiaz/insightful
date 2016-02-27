class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.string :title
      t.string :description
      t.references :user, index: true, foreign_key: true
      t.boolean :public
      t.boolean :require_login
      t.boolean :answer_is_editable

      t.timestamps null: false
    end
  end
end
