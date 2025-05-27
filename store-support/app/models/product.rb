class Product < ApplicationRecord
  enum :category, {
    electronics: "electronics",
    clothing: "clothing",
    books: "books",
    home: "home",
    other: "other"
  }

  has_many :order_items
  has_many :orders, through: :order_items

  # Validations
  validates :name, presence: true, length: { minimum: 1, maximum: 50 }
  validates :category, presence: true, inclusion: { in: categories.keys }
  validates :description, presence: true
  validates :image_url, presence: true, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [ true, false ] }
end
