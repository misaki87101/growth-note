class CreateMonthlyNotes < ActiveRecord::Migration[7.2]
  def change
    create_table :monthly_notes do |t|
      t.date :month
      t.references :group, null: false, foreign_key: true
      t.text :memo

      t.timestamps
    end
  end
end
