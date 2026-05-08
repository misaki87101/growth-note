class AddStatusToLessonArchives < ActiveRecord::Migration[7.2]
  def change
    add_column :lesson_archives, :status, :integer, default: 0, null: false
    add_index :lesson_archives, :status
  end
end
