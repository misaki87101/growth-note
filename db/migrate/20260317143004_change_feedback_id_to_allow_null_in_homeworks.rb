class ChangeFeedbackIdToAllowNullInHomeworks < ActiveRecord::Migration[7.2]
  def change
    change_column_null :homeworks, :feedback_id, true
  end
end
