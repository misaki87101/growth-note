class ChangeSecretToTextInFeedbacks < ActiveRecord::Migration[7.2]
  def change
    change_column :feedbacks, :secret, :text
  end
end
