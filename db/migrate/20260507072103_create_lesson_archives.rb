class CreateLessonArchives < ActiveRecord::Migration[7.2]
  def change
    create_table :lesson_archives do |t|
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.references :group, null: false, foreign_key: true
      t.date :lesson_date
      t.string :title
      t.text :schedule
      t.text :items
      t.text :notice

      t.timestamps
    end
  end
end
