class AddLessonArchiveIdToFeedbacks < ActiveRecord::Migration[7.2]
  def change
    add_column :feedbacks, :lesson_archive_id, :bigint
    add_index :feedbacks, :lesson_archive_id
  end
end
