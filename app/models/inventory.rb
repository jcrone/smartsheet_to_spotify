class Inventory < ApplicationRecord
  belongs_to :import
  has_many_attached :photos
end
