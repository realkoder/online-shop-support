class Api::V1::OrdersController < ApplicationController
  # GET /orders
  def index
    orders = Order.all
    render json: { data: orders.as_json(include: :order_items) }
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
    order_creation_service = OrderCreationService.new(order_params)
    order_creation_service.create

    if order_creation_service.error.nil?
      render json: { data: order_creation_service.order.as_json(include: :order_items) }, status: :ok
    else
      render json: { error: order_creation_service.error }, status: :bad_request
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
    rescue => e
      render json: { error: "Error => #{e}" }
  end

  private

  def order_params
    params.require(:order).permit(
      :client_id,
      order_items: [ :product_id, :quantity ]
    )
  end
end
