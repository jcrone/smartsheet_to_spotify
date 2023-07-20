class AddToShopifyJob < ApplicationJob

  def perform(import_id)
    @import = Import.find(import_id)
    @inventory = @import.inventories
    add_to_shopify
  end

  def add_to_shopify
    session = ShopifyAPI::Auth::Session.new(shop: Rails.application.credentials.dig(:shopify, :domain), access_token: Rails.application.credentials.dig(:shopify, :token))
    @client = ShopifyAPI::Clients::Rest::Admin.new(session: session)

    add_custom_collection

    @inventory.each do |item|
      # title is required so will skip if nil 
      if !item.columns['title'].nil? && item.photos.attached?
        send_to_shopify(item)
        sleep(2)
        #at current level only 2 calls a sec and only up to 40 call a minute
      end
    end 

  end 
    

  def send_to_shopify(item)
    add_images = []
    images = item.photos

    images.each do |image|
      image_data = image.download
      image_base = Base64.strict_encode64(image_data)
      add_images << { attachment: image_base }
    end

    body = {
      product: {
        title: item.columns['title'],
        body_html: "<strong>#{item.columns['description']}</strong> Deminsions: #{item.columns['deminsions']}",
        vendor: item.columns['mfg'],
        product_type:  item.columns['category'],
        tags: item.columns['grade'],
        variants: [
         {
           inventory_management: "shopify",
           inventory_policy: "deny",
           inventory_quantity: 10,
         }
        ],
       images: add_images
      }
    }
  
    new_item = @client.post(
      path: "products",
      body: body
    ) 
    
    product_id = new_item.body["product"]["id"] 
    add_item_to_collection(product_id)
    
  end
  
  def add_custom_collection
    body = {
      custom_collection: {
        title: @import.name
      }
    }

    custom_collection = @client.post(
      path: "custom_collections",
      body: body
    )

    @collection_id = custom_collection.body["custom_collection"]["id"]  
  end 


  def add_item_to_collection(product_id)
    body = {
      collect: {
        collection_id: @collection_id,
        product_id: product_id
      }
    }

    custom_collection = @client.post(
      path: "collects",
      body: body
    )

  end 

end 