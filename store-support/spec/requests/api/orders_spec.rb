require 'swagger_helper'

RSpec.describe '/api/v1/orders', type: :request do
  path '/orders' do
    get 'Retrieves a list of all orders' do
      response '200', 'orders found' do
        run_test!
      end
    end

    post 'Creates a new order' do
      consumes 'application/json'
      parameter name: :order, in: :body, required: true, schema: {
        type: :object,
        properties: {
          order: {
            type: :object,
            properties: {
              client_id: { type: :integer },
              order_items: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    product_id: { type: :integer },
                    quantity: { type: :integer }
                  },
                  required: %w[product_id quantity]
                }
              }
            },
            required: %w[client_id order_items]
          }
        },
        required: [ 'order' ]
      }

      response '200', 'order created' do
        let(:order) { { client_id: 1, order_items: [ { product_id: 1, quantity: 2 } ] } }
        run_test!
      end

      response '400', 'invalid request' do
        let(:order) { { client_id: nil } }
        run_test!
      end
    end
  end

  path '/orders/{id}' do
    get 'Retrieves a specific order' do
      parameter name: :id, in: :path, required: true, type: :integer

      response '200', 'order found' do
        let(:id) { Order.create(client_id: 1).id }
        run_test!
      end

      response '404', 'order not found' do
        let(:id) { 'not-found' }
        run_test!
      end
    end

    put 'Updates an existing order' do
      parameter name: :id, in: :path, required: true, type: :integer
      consumes 'application/json'
      parameter name: :order, in: :body, required: true, schema: {
        type: :object,
        properties: {
          client_id: { type: :integer },
          order_items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer },
                quantity: { type: :integer }
              }
            }
          }
        },
        required: %w[client_id order_items]
      }

      response '200', 'order updated' do
        let(:id) { Order.create(client_id: 1).id }
        let(:order) { { client_id: 1, order_items: [ { product_id: 1, quantity: 3 } ] } }
        run_test!
      end

      response '400', 'unable to update order' do
        let(:id) { 'not-found' }
        let(:order) { { client_id: nil } }
        run_test!
      end
    end

    delete 'Deletes an order' do
      parameter name: :id, in: :path, required: true, type: :integer

      response '200', 'order deleted' do
        let(:id) { Order.create(client_id: 1).id }
        run_test!
      end

      response '400', 'unable to delete order' do
        let(:id) { 'not-found' }
        run_test!
      end
    end
  end
end
