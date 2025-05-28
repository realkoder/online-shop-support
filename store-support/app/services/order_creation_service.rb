class OrderCreationService
  # Getters: order and error
  attr_reader :order, :error

  def initialize(params)
    @client_id = params[:client_id]
    @order_items = params[:order_items] || []
  end

  def create
    # Transactional so DB manipulations gets rolled back if failues
    ActiveRecord::Base.transaction do
      create_order
      process_order_items
      update_order_total
    end

    rescue => e
      set_error(e.message)
  end

  private

  def create_order
    @order = Order.create!(
      client_id: @client_id,
      status: "pending",
      total_price: 0
    )
  end

  # Need the products for price and stock to validate order can be processed
  def process_order_items
    product_ids = @order_items.map { |item| item[:product_id] }.uniq
    @products = Product.where(id: product_ids).index_by(&:id)

    @order_items.each do |item|
      product = find_product(item[:product_id].to_i)
      validate_stock(product, item[:quantity].to_i)
      update_product_stock(product, item[:quantity].to_i)
      create_order_item(product, item[:quantity])
    end
  end

  def find_product(item_product_id)
    product = @products[item_product_id]
    raise "Product with id #{item_product_id} not found" unless product
    product
  end

  def validate_stock(product, quantity)
    return if product.stock >= quantity
    raise "Not enough products in stock for #{product.name}"
  end

  def update_product_stock(product, quantity)
    product.stock -= quantity
    product.save!
  end

  def create_order_item(product, quantity)
    OrderItem.create!(
      order: @order,
      product: product,
      quantity: quantity,
      price: product.price
    )
  end

  def update_order_total
    @order.update!(
      total_price: @order.order_items.sum { |item| item.price * item.quantity }
    )
  end

  def set_error(message)
    # Conditionally assign - if message is falsy error will be set - ensuring @error is set only once
    @error ||= message
  end
end
