class ChangeFeedbackIdToNullableInCommentsAndLikes < ActiveRecord::Migration[7.0]
  def change
    # comments テーブルの feedback_id の NOT NULL 制約を解除
    change_column_null :comments, :feedback_id, true
    
    # likes テーブルの feedback_id の NOT NULL 制約を解除
    change_column_null :likes, :feedback_id, true
  end
end