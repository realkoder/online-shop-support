class Product < ApplicationRecord
  enum :category, {
    electronics: 'electronics',
    clothing: 'clothing',
    books: 'books',
    home: 'home',
    other: 'other'
  }

  has_many :order_items
  has_many :orders, through: :order_items
end