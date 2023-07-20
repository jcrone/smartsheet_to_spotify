class AddInventoryJob < ApplicationJob
  queue_as :default
  require 'smartsheet'
  require "down/http"
  require 'securerandom'

  def perform(import_id)
    @import = Import.find(import_id)
    add_inventory
  end

  def add_inventory
    smartsheet_client = Smartsheet::Client.new(token:  Rails.application.credentials.dig(:smartsheets, :token))
    sheet = smartsheet_client.sheets.get(
      sheet_id: @import.smartsheet_id
    )
    attachments = smartsheet_client.sheets.attachments.list(
      sheet_id: @import.smartsheet_id
    )
    @photos = attachments[:data]

    rows = sheet[:rows]
    column_keys = @import.columns

    rows.each do |row|
      new_item = Inventory.new
      columns = row[:cells]   
      i = 1
      column_keys.each do |column_key|
        new_column = columns.find {|c| c[:column_id] == column_key[1].to_i }
        new_item.columns[column_key[0]] = new_column[:display_value]
        i += 1     
      end
      
      new_item.row_id = row[:id]
      new_item.row = row[:row_number].to_i
      
      new_item.import_id = @import.id
      if new_item.save
        row_photos =  @photos.select {|p| p[:parent_id] == row[:id]}
        row_photos.each  do |row_photo|
          attachment = smartsheet_client.sheets.attachments.get(
            sheet_id: @import.smartsheet_id,
            attachment_id: row_photo[:id]
          )
          temp_photo = Down::Http.download(attachment[:url], extension: "jpg")
          p "🔥🔥🔥🔥: ATTACHMENTS :: #{temp_photo}"
          new_item.photos.attach(
            io: File.open(temp_photo.path),
            filename: "#{SecureRandom.hex}.jpg", 
            content_type: "image/jpeg"
          )
        end
        new_item.save
      end
      @import.status = "complete"
      @import.save
    end  

  end 
end
