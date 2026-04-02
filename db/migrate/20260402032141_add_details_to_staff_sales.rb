class AddDetailsToStaffSales < ActiveRecord::Migration[7.2]
  def change
    add_column :staff_sales, :start_time, :string
    add_column :staff_sales, :end_time, :string
    add_column :staff_sales, :break_time, :integer
  end
end
