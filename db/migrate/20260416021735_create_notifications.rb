class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.integer :recipient_id
      t.integer :actor_id
      t.string :action
      t.integer :notifiable_id
      t.string :notifiable_type
      t.datetime :read_at

      t.timestamps
    end
    add_index :notifications, :recipient_id
  end
end
