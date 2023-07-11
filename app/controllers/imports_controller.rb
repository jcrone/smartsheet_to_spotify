class ImportsController < ApplicationController
  before_action :set_import, only: %i[ show edit update destroy ]

  # GET /imports or /imports.json
  def index
    @imports = Import.all
  end

  # GET /imports/1 or /imports/1.json
  def show
  end

  # GET /imports/new
  def new
    @smartsheet_id = params[:smartsheet_id].to_i
    smartsheet_client = Smartsheet::Client.new(token:  Rails.application.credentials.dig(:smartsheets, :token))
    unless @smartsheet_id == 0
      sheet = smartsheet_client.sheets.get(
        sheet_id: @smartsheet_id
      )
      
      @sheet = sheet[:rows]
      columns = sheet[:columns]
      @columns = columns.pluck(:title)
      # binding.break
    end
    @import = Import.new
    
    session = ShopifyAPI::Utils::SessionUtils.load_current_session(
      auth_header: auth_header,
      cookies: cookies,
      is_online: is_online
    )
    client = ShopifyAPI::Clients::Rest::Admin.new(
      session: session
    )
    @response = client.get(path: 'shop')

    console

  end

  # Title  - product.title = "Burton Custom Freestyle 151"       
  # Body   - product.body_html = "<strong>Good snowboard!</strong>"
  # Vendor - product.vendor = "Burton"
  # ProductType - product.product_type = "Snowboard"
  # ProductDemisions - Add this to the product body
  # Grade - product.tags = ["Used"]




  # GET /imports/1/edit
  def edit
  end

  # POST /imports or /imports.json
  def create
    @import = Import.new(import_params)

    respond_to do |format|
      if @import.save
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
      params.require(:import).permit(:smartsheet_id, :headers, :status, :name)
    end
end
