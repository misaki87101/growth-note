class AddAcceptedToGroupUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :group_users, :accepted, :boolean, default: false
  end
end
