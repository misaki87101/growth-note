class CreateDailyReports < ActiveRecord::Migration[7.2]
  def change
    create_table :daily_reports do |t|
      t.integer :group_id
      t.date :date
      t.integer :staff_count
      t.integer :new_customers
      t.integer :repeat_customers
      t.string :referral_source
      t.integer :tech_sales
      t.integer :item_sales
      t.integer :tech_target
      t.integer :item_target
      t.float :total_working_hours

      t.timestamps
    end
  end
end
