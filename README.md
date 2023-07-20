# README

This README would normally document whatever steps are necessary to get the
application up and running.

you need

* Ruby 3.1.3
* Rails ~> 7.0.5
* Redis for background jobs 
* Postgres Database

# Generate Smartsheet token 
This will help you generate a smartsheet token
https://help.smartsheet.com/articles/2482389-generate-API-key

# You need your shopify Token
Go to your shopify store and select settings in the setting menu select apps and sales channels then select the Develop apps, create an app
configure your appd with the scopes 
* Inventory (all inventory scopes)
* Product (all product scopes)
* Order 
Once you generate it you will need to copy your token, this will be your access to the store