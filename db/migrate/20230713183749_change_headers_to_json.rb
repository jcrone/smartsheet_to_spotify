class ChangeHeadersToJson < ActiveRecord::Migration[7.0]
  def change
    add_column :imports, :columns, :json, default: {}
  end
end
