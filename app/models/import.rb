class Import < ApplicationRecord
  has_many :inventories, dependent: :destroy 
end
