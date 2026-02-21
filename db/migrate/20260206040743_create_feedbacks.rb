class CreateFeedbacks < ActiveRecord::Migration[7.2]
  def change
    create_table :feedbacks do |t|
      t.references :student, null: false, foreign_key: { to_table: :users }
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.date :lesson_date
      t.integer :evaluation
      t.text :lesson_content
      t.text :issue
      t.text :content

      t.timestamps
    end
  end
end
