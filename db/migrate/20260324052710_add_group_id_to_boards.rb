class AddGroupIdToBoards < ActiveRecord::Migration[7.2]
  def change
    add_column :boards, :group_id, :integer
  end
end
