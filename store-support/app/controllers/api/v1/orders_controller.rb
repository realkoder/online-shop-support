class Api::V1::OrdersController < ApplicationController
  # GET /orders
  def index
    orders = Order.all
    render json: { data: orders }
  end

  # GET /orders/:id
  def show
    order = Order.find(params[:id])
    render json: { data: order }
  rescue
    render json: { data: nil }
  end

  # POST /orders
  def create
    # Transactional so DB manipulations gets rolled back if failues
    ActiveRecord::Base.transaction do
      # IMPORTANT check if product stock amount is acceptable for incoming order
      order_items_params = order_params[:order_items] || []

      order = Order.create(client_id: order_params[:client_id], status: "pending", total_price: 0)
      Rails.logger.info("LOOK ORDERID: #{order.id}")

      # Need the products for price and stock
      product_ids = order_items_params.map { |item| item[:product_id] }
      products = Product.where(id: product_ids).index_by(&:id)

      order_items = []
      order_total_price = 0

      order_items_params.each do |item|
        product = products[item[:product_id].to_i]
        quantity = item[:quantity].to_i
        Rails.logger.info("LOOK #{product.stock}")

        if product.nil?
          render json: { error: "Product with id #{item[:product_id]} not found" }, status: 400
          raise ActiveRecord::Rollback
        end

        if product.stock < quantity
          render json: { error: "Not enough stock for product #{product.name}" }, status: 400
          raise ActiveRecord::Rollback
        end

        product.stock -= quantity
        product.save! # ! will raise an error if saving fails - then DB is rolled back

        order_item = OrderItem.create(order_id: order.id, product_id: product.id, quantity: quantity, price: product.price)
        # Associates order_items with order and gets persisted when order.save executes
        order_items << order_item

        order_total_price += product.price * quantity
      end

      order.total_price = order_total_price

      if order.save
        render json: { data: order.as_json(include: :order_items) }, status: 200
      else
        render json: { error: "Unable to create Order." }, status: 400
        raise ActiveRecord::Rollback
      end
    end
  end

  # PUT /orders/:id
  def update
    order = Order.find(params[:id])
    if order
      order.update(order_params)
      render json: { data: order }, status: 200
    else
      render json: { error: "Unable to update Order." }, status: 400
    end
  end

  # DELETE /orders/:id
  def destroy
    order = Order.find(params[:id])
    if order
      order.destroy
      render json: { message: "Order with id: #{order.id} deleted." }, status: 200
    else
      render json: { error: "Unable to delete Order with id: #{order.id}." }, status: 400
    end
  end

  private

  def order_params
    params.require(:order).permit(
      :client_id,
      order_items: [ :product_id, :quantity ]
    )
  end
end
