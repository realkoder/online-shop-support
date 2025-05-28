class Api::V1::ProductsController < ApplicationController
  # GET /products
  def index
    products = Product.all
    render json: { data: products }
  end

  # GET /products/:id
  def show
    product = Product.find(params[:id])
    render json: { data: product }
  rescue
    render json: { data: nil }
  end

  # POST /products
  def create
    product = Product.new(product_params)
    if product.save
      render json: { data: product }, status: 200
    else
      render json: { error: "Unable to create Product." }, status: 400
    end
  end

  # PUT /products/:id
  def update
    product = Product.find(params[:id])
    if product
      # Bang version ensures that validations gets triggered and throws if not valid
      product.update!(product_params)
      render json: { data: product }, status: 200
    else
      render json: { error: "Unable to update Product." }, status: 400
    end
    rescue => e
      render json: { error: "Error => #{e}" }
  end

  # DELETE /products/:id
  def destroy
    product = Product.find(params[:id])
    if product
      product.destroy
      render json: { message: "Product with id: #{product.id} deleted." }, status: 200
    else
      render json: { error: "Unable to delete Product with id: #{product.id}." }, status: 400
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :category, :description, :image_url, :price, :stock, :active)
  end
end
