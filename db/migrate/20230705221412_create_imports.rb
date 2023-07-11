class CreateImports < ActiveRecord::Migration[7.0]
  def change
    create_table :imports do |t|
      t.string :smartsheet_id
      t.string :headers, array: true, default: []
      t.string :status
      t.string :name

      t.timestamps
    end
  end
end
