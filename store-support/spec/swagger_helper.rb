# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s


  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Simple Order and Product Supporti for E-Shop API V1',
        version: 'v1'
      },
      paths: {},
      components: {
        schemas: {
          not_found: {
            type: 'object',
            properties: {
              error: { type: :string }
            }
          },
          order: {    # Definition for Order
            type: 'object',
            required: [ :client_id, :total_price, :total_items, :status ],  # Required fields
            properties: {
              client_id: {
                type: :integer,
                example: 1
              },
              total_price: {
                type: :decimal,
                example: 119.99,
                description: "Total price of the order"
              },
              total_items: {
                type: :integer,
                example: 2,
                description: "Total number of items in the order"
              },
              status: {
                type: :string,
                example: "pending",  # Example values for order status
                enum: [ "pending", "paid", "shipped", "cancelled", "completed" ]
              }
            }
          },
          product: {    # Definition for Product
            type: 'object',
            required: [ :name, :category, :description, :price, :stock ],
            properties: {
              name: {
                type: :string,
                example: "Espresso"
              },
              category: {
                type: :string,
                example: "beverages"
              },
              description: {
                type: :string,
                example: "A hot beverage made by forcing pressurized water through finely-ground coffee."
              },
              price: {
                type: :decimal,
                example: 1.99,
                description: "Price of the product"
              },
              stock: {
                type: :integer,
                example: 50,
                description: "Available stock of the product"
              },
              active: {
                type: :boolean,
                example: true,
                description: "Indicates if the product is active and available for sale"
              }
            }
          }
        }
      },
      servers: [
        {
          url: 'http://localhost:3000/api/v1',
          variables: {
            defaultHost: {
              default: 'http://localhost:3000/api/v1'
            }
          }
        }
      ]
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
