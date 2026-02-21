class AddTimestampToCheckItems < ActiveRecord::Migration[7.2]
  def change
    add_column :check_items, :timestamp, :string
  end
end
