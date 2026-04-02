class AddGroupIdToUsers < ActiveRecord::Migration[7.0]
  def change
    # null: false を null: true に変更、または null の記述を消す
    add_reference :users, :group, null: true, foreign_key: true
  end
end