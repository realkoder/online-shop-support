class Api::V1::ProductsController < ApplicationController
  def index
    products = Product.all
    render json: { data: products }
  end

  def show
    product = Product.find(params[:id])
    render json: { data: product }
  rescue
    render json: {data: nil }
  end

  def new
    product = Product.new
    render json: { data: product }
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to product
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to @product
    else
      render :edit, status: :unprocessable_entity
    end
  end

end
