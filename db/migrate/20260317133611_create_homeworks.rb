class CreateHomeworks < ActiveRecord::Migration[7.2]
  def change
    create_table :homeworks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :feedback, null: false, foreign_key: true
      t.date :lesson_date
      t.text :content
      t.integer :hour
      t.integer :minute

      t.timestamps
    end
  end
end
