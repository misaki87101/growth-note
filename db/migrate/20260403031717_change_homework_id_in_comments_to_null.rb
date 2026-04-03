class ChangeHomeworkIdInCommentsToNull < ActiveRecord::Migration[7.2]
  def change
    # false (空NG) から true (空OK) に変更
    change_column_null :comments, :homework_id, true
  end
end