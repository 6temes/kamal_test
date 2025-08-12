class Product < ApplicationRecord
  # Broadcast refreshes to the "products" stream for all CRUD operations
  broadcasts_refreshes_to ->(product) { "products" }
end
