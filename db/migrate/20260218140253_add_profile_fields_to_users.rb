class AddProfileFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :bio, :text
    add_column :users, :goals, :text
    add_column :users, :features, :text
    add_column :users, :favorite_things, :text
    add_column :users, :message, :text
  end
end
