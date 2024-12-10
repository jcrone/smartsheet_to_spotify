class ImportsController < ApplicationController
  require 'base64'
  before_action :set_import, only: %i[ show edit update destroy send_to_shopify ]

  # GET /imports or /imports.json
  def index
    @imports = Import.all
  end

  # GET /imports/1 or /imports/1.json
  def show
    session = ShopifyAPI::Auth::Session.new(shop: Rails.application.credentials.dig(:shopify, :domain), access_token: Rails.application.credentials.dig(:shopify, :token))
    client = ShopifyAPI::Clients::Rest::Admin.new(session: session)
    @response = client.get(path: 'shop')
    # binding.break
    console
  end

  # GET /imports/new
  def new
    @smartsheet_id = params[:smartsheet_id].to_i
    smartsheet_client = Smartsheet::Client.new(token:  Rails.application.credentials.dig(:smartsheets, :token))

    shopify_session = ShopifyAPI::Auth::Session.new(shop: Rails.application.credentials.dig(:shopify, :domain), access_token: Rails.application.credentials.dig(:shopify, :token))
    @shopify_client = ShopifyAPI::Clients::Rest::Admin.new(session: shopify_session)

    @colletions = @shopify_client.get(path: "products")

    session = ShopifyAPI::Auth::Session.new(
      shop: Rails.application.credentials.dig(:shopify, :domain),
      access_token: Rails.application.credentials.dig(:shopify, :token)
    )
    client = ShopifyAPI::Clients::Graphql::Admin.new(
      session: session
    )
    console
    query = <<~QUERY
      query {
        collections(first: 100) {
          edges {
            node {
              id
              title
              handle
              updatedAt
              sortOrder
            }
          }
        }
      }
    QUERY
    @response = client.query(query: query)
    @collections_dropdown = Array.new
    @testing = @response.body['data']['collections']['edges']
    @testing.each do |dropdown|
      print dropdown
      temp_collection = Array.new << dropdown['node']['title'] << dropdown['node']['id'].chars.last(12).join
      @collections_dropdown << temp_collection
    end 

    unless @smartsheet_id == 0
      sheet = smartsheet_client.sheets.get(
        sheet_id: @smartsheet_id
      )
      
      @sheet = sheet[:rows]
      columns = sheet[:columns]
      @columns = columns.pluck(:id, :title)
    end

    @import = Import.new
  end

  def send_to_shopify
    AddToShopifyJob.perform_later(@import.id)
    redirect_to import_url(@import), notice: "In the process of sending to shopify."
  end

  # GET /imports/1/edit
  def edit
  end


  # POST /imports or /imports.json
  def create
    @import = Import.new(import_params)

    respond_to do |format|
      if @import.save
        AddInventoryJob.perform_later(@import.id)
        format.html { redirect_to import_url(@import), notice: "Import was successfully created." }
        format.json { render :show, status: :created, location: @import }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /imports/1 or /imports/1.json
  def update
    respond_to do |format|
      if @import.update(import_params)
        format.html { redirect_to import_url(@import), notice: "Import was successfully updated." }
        format.json { render :show, status: :ok, location: @import }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @import.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /imports/1 or /imports/1.json
  def destroy
    @import.destroy

    respond_to do |format|
      format.html { redirect_to imports_url, notice: "Import was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_import
      @import = Import.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def import_params
      params.require(:import).permit(:smartsheet_id, {columns: {}}, :status, :name, :collections_id)
    end
end
