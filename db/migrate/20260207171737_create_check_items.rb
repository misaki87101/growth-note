class CreateCheckItems < ActiveRecord::Migration[7.2]
  def change
    create_table :check_items do |t|
      t.references :feedback, null: false, foreign_key: true
      t.string :name
      t.string :result

      t.timestamps
    end
  end
end
