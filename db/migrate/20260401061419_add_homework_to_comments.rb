class AddHomeworkToComments < ActiveRecord::Migration[7.2]
  def change
    add_reference :comments, :homework, null: false, foreign_key: true
  end
end
