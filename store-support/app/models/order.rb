class Order < ApplicationRecord
  enum :status, {
    pending: 'pending',
    paid: 'paid',
    shipped: 'shipped',
    cancelled: 'cancelled',
    completed: 'completed'
  }

  belongs_to :client
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
end
