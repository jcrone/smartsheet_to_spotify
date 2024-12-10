class AddCollectionsIdToImport < ActiveRecord::Migration[7.0]
  def change
    add_column :imports, :collections_id, :string
  end
end
