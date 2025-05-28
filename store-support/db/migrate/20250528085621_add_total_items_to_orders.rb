class AddTotalItemsToOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :orders, :total_items, :integer, null: false, default: 0
  end
end
