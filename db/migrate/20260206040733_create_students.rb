class CreateStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :students do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.text :background
      t.text :feature

      t.timestamps
    end
  end
end
