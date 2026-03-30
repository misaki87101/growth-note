class AddMemoToDailyReports < ActiveRecord::Migration[7.2]
  def change
    add_column :daily_reports, :memo, :text
  end
end
