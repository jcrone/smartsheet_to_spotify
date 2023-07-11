ShopifyAPI::Context.setup(
    api_key:  Rails.application.credentials.dig(:shopify, :api_key) 
    api_secret_key: Rails.application.credentials.dig(:shopify, :api_secret_key),
    host_name: "SmartSheetImport",
    scope: "read_orders,read_products,etc",
    is_embedded: true, # Set to true if you are building an embedded app
    is_private: false, # Set to true if you are building a private app
    api_version: "2021-01" # The version of the API you would like to use
  )