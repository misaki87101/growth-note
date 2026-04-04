class AddSecretToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :secret, :boolean
  end
end
