require 'swagger_helper'

RSpec.describe 'api/v1/products', type: :request do
  path '/products' do
    get 'Retrieves a list of all products' do
      response '200', 'products found' do
        run_test!
      end
    end

    post 'Creates a new product' do
      consumes 'application/json'
      parameter name: :product, in: :body, required: true, schema: {
        type: :object,
        properties: {
          name: {
            type: :string,
            example: "Tablet v.2.0"
          },
          category: { type: :string, example: "electronics" },
          description: { type: :string, example: "Just a tablet" },
          image_url: { type: :string, example: "https://images.pexels.com/photos/221185/pexels-photo-221185.jpeg"  },
          price: { type: :float, example: 99.9 },
          stock: { type: :integer, example: 5 },
          active: { type: :boolean, example: true }
        }
      }

      response '200', 'product created' do
        let(:product) { { name: 'Espresso', category: 'beverages', description: 'A hot beverage.', price: 1.99, stock: 50, active: true } }
        run_test!
      end

      response '400', 'invalid request' do
        let(:product) { { name: nil } }
        run_test!
      end
    end
  end

  path '/products/{id}' do
    get 'Retrieves a specific product' do
      parameter name: :id, in: :path, required: true, type: :integer

      response '200', 'product found' do
        let(:id) { Product.create(name: 'Espresso').id }
        run_test!
      end

      response '404', 'product not found' do
        let(:id) { 'not-found' }
        run_test!
      end
    end

    put 'Updates an existing product' do
      parameter name: :id, in: :path, required: true, type: :integer
      consumes 'application/json'
      parameter name: :product, in: :body, required: true, schema: {
        type: :object,
        properties: {
          name: {
            type: :string,
            example: "Tablet v.2.0"
          },
          category: { type: :string, example: "electronics" },
          description: { type: :string, example: "Just a tablet" },
          image_url: { type: :string, example: "https://images.pexels.com/photos/221185/pexels-photo-221185.jpeg"  },
          price: { type: :float, example: 99.9 },
          stock: { type: :integer, example: 5 },
          active: { type: :boolean, example: true }
        }
      }

      response '200', 'product updated' do
        let(:id) { Product.create(name: 'Espresso').id }
        let(:product) { { name: 'New Espresso' } }
        run_test!
      end

      response '400', 'unable to update product' do
        let(:id) { 'not-found' }
        let(:product) { { name: nil } }
        run_test!
      end
    end

    delete 'Deletes a product' do
      parameter name: :id, in: :path, required: true, type: :integer

      response '200', 'product deleted' do
        let(:id) { Product.create(name: 'Espresso').id }
        run_test!
      end

      response '400', 'unable to delete product' do
        let(:id) { 'not-found' }
        run_test!
      end
    end
  end
end
