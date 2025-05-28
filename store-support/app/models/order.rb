class Order < ApplicationRecord
  enum :status, {
    pending: "pending",
    paid: "paid",
    shipped: "shipped",
    cancelled: "cancelled",
    completed: "completed"
  }

  belongs_to :client
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  # Validations
  validates :client_id, presence: true
  validates :status, presence: true, inclusion: { in: statuses.keys }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :total_items, presence: true, numericality: { greater_than_or_equal_to: 0 }
end
