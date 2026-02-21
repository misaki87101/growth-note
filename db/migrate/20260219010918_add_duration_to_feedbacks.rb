class AddDurationToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :duration, :integer
  end
end
