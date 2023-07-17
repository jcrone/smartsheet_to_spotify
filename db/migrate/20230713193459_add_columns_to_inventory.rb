class AddColumnsToInventory < ActiveRecord::Migration[7.0]
  def change
    add_column :inventories, :columns, :json, default: {}
  end
end
