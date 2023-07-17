class CreateInventories < ActiveRecord::Migration[7.0]
  def change
    create_table :inventories do |t|
      t.belongs_to :import, null: false, foreign_key: true
      t.string :row_id
      t.string :headers, array: true, default: []

      t.timestamps
    end
  end
end
