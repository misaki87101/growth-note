class AddHoursAndMinutesToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :hour, :integer
    add_column :feedbacks, :minute, :integer
  end
end
