class CreateStaffSales < ActiveRecord::Migration[7.2]
  def change
    create_table :staff_sales do |t|
      t.references :daily_report, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :tech_sales
      t.integer :item_sales
      t.float :working_hours

      t.timestamps
    end
  end
end
