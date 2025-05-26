# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# ========================================================================

# RESET TO A FRESH BEGINNING
OrderItem.destroy_all
Order.destroy_all
Client.destroy_all
Product.destroy_all

# Reset primary key sequences (for PostgreSQL, SQLite, MySQL)
tables = %w[order_items orders clients products]
tables.each do |table|
  ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='#{table}'")
end

# ===========
# clients
# ===========
clients = [
  { fullname: "Alice Johnson", email: "alice@example.com", phone: "555-1234", image_url: "https://randomuser.me/api/portraits/women/1.jpg" },
  { fullname: "Bob Smith", email: "bob@example.com", phone: "555-5678", image_url: "https://randomuser.me/api/portraits/men/2.jpg" },
  { fullname: "Carol Lee", email: "carol@example.com", phone: "555-8765", image_url: "https://randomuser.me/api/portraits/women/3.jpg" },
  { fullname: "David Kim", email: "david@example.com", phone: "555-4321", image_url: "https://randomuser.me/api/portraits/men/4.jpg" }
]

clients.each do |attrs|
  Client.find_or_create_by!(email: attrs[:email]) do |client|
    client.fullname = attrs[:fullname]
    client.phone = attrs[:phone]
    client.image_url = attrs[:image_url]
  end
end

# ===========
# products
# ===========
products = [
  {
    name: "Lipstick",
    category: "other",
    description: "A red lipstick.",
    image_url: "https://cdn.pixabay.com/photo/2021/10/10/21/52/makeup-6698881_1280.jpg",
    price: 99.99,
    stock: 50,
    active: true
  },
  {
    name: "Classic T-Shirt",
    category: "clothing",
    description: "100% cotton classic t-shirt, available in multiple colors.",
    image_url: "https://cdn.pixabay.com/photo/2016/11/29/12/51/man-1869624_1280.jpg",
    price: 19.99,
    stock: 200,
    active: true
  },
  {
    name: "Modern Bookshelf",
    category: "home",
    description: "Stylish bookshelf to organize your books and decor.",
    image_url: "https://cdn.pixabay.com/photo/2017/08/06/22/01/books-2596809_1280.jpg",
    price: 149.99,
    stock: 20,
    active: true
  },
  {
    name: "Bestselling Novel",
    category: "books",
    description: "A gripping novel from a bestselling author.",
    image_url: "https://cdn.pixabay.com/photo/2014/08/16/18/17/book-419589_1280.jpg",
    price: 14.99,
    stock: 100,
    active: true
  },
  {
    name: "Record Player",
    category: "electronics",
    description: "Portable record player.",
    image_url: "https://cdn.pixabay.com/photo/2020/04/02/10/00/record-player-4994400_1280.jpg",
    price: 500.00,
    stock: 500,
    active: true
  }
]

products.each do |attrs|
  Product.find_or_create_by!(name: attrs[:name]) do |product|
    product.category = attrs[:category]
    product.description = attrs[:description]
    product.image_url = attrs[:image_url]
    product.price = attrs[:price]
    product.stock = attrs[:stock]
    product.active = attrs[:active]
  end
end

# ===========
# orders
# ===========
clientAlice = Client.find_by(email: "alice@example.com")
clientBob = Client.find_by(email: "bob@example.com")
product1 = Product.find_by(name: "Record Player")
product2 = Product.find_by(name: "Classic T-Shirt")
product3 = Product.find_by(name: "Modern Bookshelf")

orders = [
  {
    client: clientAlice,
    status: "pending",
    total_price: 119.98
  },
  {
    client: clientBob,
    status: "completed",
    total_price: 149.99
  }
]

order_records = orders.map do |attrs|
  Order.find_or_create_by!(client: attrs[:client], status: attrs[:status]) do |order|
    order.total_price = attrs[:total_price]
  end
end

order1 = order_records[0]
order2 = order_records[1]

# ===========
# order_items
# ===========
order_items = [
  {
    order: order1,
    product: product1,
    quantity: 1,
    price: product1.price
  },
  {
    order: order1,
    product: product2,
    quantity: 1,
    price: product2.price
  },
  {
    order: order2,
    product: product3,
    quantity: 1,
    price: product3.price
  }
]

order_items.each do |attrs|
  OrderItem.find_or_create_by!(order: attrs[:order], product: attrs[:product]) do |order_item|
    order_item.quantity = attrs[:quantity]
    order_item.price = attrs[:price]
  end
end