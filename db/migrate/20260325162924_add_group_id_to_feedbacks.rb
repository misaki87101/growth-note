class AddGroupIdToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :group_id, :integer
  end
end
