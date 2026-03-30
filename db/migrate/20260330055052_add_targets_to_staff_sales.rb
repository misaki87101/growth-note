class AddTargetsToStaffSales < ActiveRecord::Migration[7.2]
  def change
    add_column :staff_sales, :tech_target, :integer
    add_column :staff_sales, :item_target, :integer
  end
end
