class AddHomeworkToLikes < ActiveRecord::Migration[7.2]
  def change
    add_reference :likes, :homework, null: false, foreign_key: true
  end
end
