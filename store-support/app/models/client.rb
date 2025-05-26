class Client < ApplicationRecord
  has_many :orders # dependent: :destroy // uncomment to add cascading deletion
end
