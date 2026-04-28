class AddStatusToFeedbacks < ActiveRecord::Migration[7.0]
  def change
    # default: 0 (下書き), null: false (空を許可しない) を追加
    add_column :feedbacks, :status, :integer, default: 0, null: false
    
    # 検索を速くするためにインデックスも貼っておく
    add_index :feedbacks, :status
  end
end