class SmartsheetsController < ApplicationController
    require 'smartsheet'

    def index     
        smartsheet_client = Smartsheet::Client.new(token:  Rails.application.credentials.dig(:smartsheets, :token))
        response = smartsheet_client.sheets.list
        folder = smartsheet_client.folders.get(
            folder_id: 3311689245452164
          )
 
        @sheets =  folder[:sheets]
        
    end
 
    private

  end