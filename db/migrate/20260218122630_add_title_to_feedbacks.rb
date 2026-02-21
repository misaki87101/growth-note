class AddTitleToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :title, :string
  end
end
