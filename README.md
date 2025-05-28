# Support Application for an Online Shop 🛍️

Although I'm not **yet** fluent in _Ruby & Ruby on Rails_, I enjoy a good challenge. That’s why I’m excited to take on this task using _Ruby on Rails_ as a full stack framework. This document will serve as a record of my process and maybe you’ll find it interesting too. 📚

---

<br>

## Assignment 📋

```text
Create an application to support an online shop.

Limit to have entities like product and order only. (You can add client if want to).

The application must have an API to expose data.

There is no right or wrong answer the goal is to have a baseline to discuss about your approach and development process.

Just consider the volume of data the application has to handle.

The usage of AI is OK.

All the stack of development is free to your choice.
```

---

<br>

## Setting up the Ruby on Rails Project 👷‍♀️

[Ruby on Rails guide](https://guides.rubyonrails.org/getting_started.html)

I'm using _Cursor_ as _IDE_ and for the _Ruby on Rails_ project I'm using _Ruby LSP shopify_ extension for linting and formatting etc.

**Create a new Rails project**

- Ensure that `rails` is added as _gem_ (check by runing `rails -v`):

```bash
# Using api flag since building REST API and not a full stack application
rails new store-support --api
```

- This project is using `Rails 8.0.2`
- The _Rails project_ is now generated and ready to build upon. Enter the `store-support` directory. **Ensure to always use `bin/rails` when running Rails CLI commands to ensure compatibility.**
- Start the server `bin/rails server`

**The codebase is now configured - let's CODE 💻**

<br>

---

## Rails migrations / Active Records

_Rails_ is by default configured with _SQLite3_, which will be used for simplicity.

Default as well in a _Rails_ project with SQLite3, the database is persisted as a file located at: `store-support/storage/development.sqlite3` for the dev env configured in `store-support/config/database.yml`.

([Rails Migration Difference between Text and String](https://www.rubyinrails.com/2014/03/16/rails-migration-difference-between-text-and-string/))

---

#### Client 👩‍🔧🙎‍♂️

**Using a SIMPLE _Client_ model where _address_ etc is omitted:**

- `fullname` (string): Full name of the client.
- `email` (string): Email address of the client.
- `phone` (string): Phone number of the client.
- `image_url` (string): Link to the client’s profile image.

`bin/rails cli` to define the Active Records.

```bash
bin/rails generate model Client fullname:string email:string phone:string image_url:string
```

---

#### Product 📦

**_Product_ model:**

- `name` (string): Name of product.
- `category` (enum): Keeping it simple, if it was correct is should be _has_many_ e.g., electronics, clothing, books, home, other.
- `description` (string): Detailed description of product.
- `image_url` (string): Link to a product image.
- `price` (float): Cost of product.
- `stock` (integer): Number of items in stock.
- `active` (boolean): Is product available for sale.

`bin/rails cli` to define the Active Records.

```bash
bin/rails generate model Product name:string category:string description:text image_url:string price:decimal stock:integer active:boolean
```

After generating the model, define the enum in `app/models/product.rb`:

```ruby
class Product < ApplicationRecord
  enum :category, {
    electronics: 'electronics',
    clothing: 'clothing',
    books: 'books',
    home: 'home',
    other: 'other'
  }
end
```

---

#### Order 📜

**_Orders model_:**

- `client_id` (references): Foreign key to the client who placed the order.
- `status` (enum): e.g., pending, paid, shipped, cancelled, completed.
- `total_price` (decimal): Total price of the order.

Using `bin/rails cli` to define the Active Records.

```bash
bin/rails generate model Order client:references status:string total_price:decimal
```

After generating the model, define the enum in `app/models/Order.rb`:

```ruby
class Order < ApplicationRecord
  enum :status, {
    pending: 'pending',
    paid: 'paid',
    shipped: 'shipped',
    cancelled: 'cancelled',
    completed: 'completed'
  }
end
```

---

#### OrderItem

**_OrderItem model_:**

- `order_id` (references): Foreign key to the order.
- `product_id` (references): Foreign key to the product.
- `quantity` (integer): Number of ordered products.

Using `bin/rails cli` to define the Active Records.

```bash
bin/rails generate model OrderItem order:references product:references quantity:integer price:decimal
```

**After Order and OrderItem creation ensure that the associations are present**

`store-support/app/models/order.rb`

```ruby
class Order < ApplicationRecord
  belongs_to :client
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
end
```

`store-support/app/models/order_item.rb`

```ruby
class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
end
```

`store-support/app/models/product.rb`

[Many-to-many relation: has_many :orders, through: :order_items](https://guides.rubyonrails.org/association_basics.html)

```ruby
class Product < ApplicationRecord
  has_many :order_items
  has_many :orders, through: :order_items
end
```

`store-support/app/models/client.rb`

```ruby
class Client < ApplicationRecord
  has_many :orders # dependent: :destroy // uncomment to add cascading deletion
end
```

---

### Activate the created migrations

Now we have created the migrations for the needed _Active Records_ at `store-support/db/migrate` run the migration:

```bash
# Running the migration
bin/rails db:migrate

# Rollback latest migration
bin/rails db:rollback

# Activate Rails Console
bin/rails console

# Ensure the migration have been enabled correctly by
ActiveRecord::Base.connection.tables
=> ["order_items", "orders", "clients", "products", "ar_internal_metadata", "schema_migrations"]

# Ensure the correct column names exists as well
store-support(dev)> Client.column_names
=> ["id", "fullname", "email", "phone", "image_url", "created_at", "updated_at"]
store-support(dev)> Product.column_names
=> ["id", "name", "category", "description", "image_url", "price", "stock", "active", "created_at", "updated_at"]
store-support(dev)> Order.column_names
=> ["id", "client_id", "status", "total_price", "created_at", "updated_at"]
store-support(dev)> OrderItem.column_names
=> ["id", "order_id", "product_id", "quantity", "price", "created_at", "updated_at"]
```

---

### Migrations: Adding new fields

Forgot to add `totalItems` for _orders_ - which can be done with another migration.

```bash
# Generate the migration
bin/rails generate migration AddTotalItemsToOrders total_items:integer

# Execute the new migration
bin/rails db:migrate
```

---

#### Seeding DB 🌾

By seeding the DB we have some mocked data for the dev env to play with, the seed logic is always tearing down all tables and id sequences to start from a fresh when executed.

[Check out the seed here](./store-support/db/seeds.rb)

Run the seed:

```bash
bin/rails db:seed

# To reset db -> drops DB, creates a new empty database, run migrations, run seeds
bin/rails db:reset
```

## Routing 🚏

It's important that `orders` and `products` can be requested by the REST API based application.

The REST API will expose _CRUD endpoints_ for the following two controllers: `store-support/app/controllers/products` & `store-support/app/controllers/products`

The controllers are referenced in `store-support/config/routes.rb` to ensure proper routing when server is requested.

```ruby
  namespace :api do
    namespace :v1 do
      # Could have added this if we wanted to rely on #index as returning a view
      # get 'products/all', to: 'products#all'
      resources :products

      # Could have added this if we wanted to rely on #index as returning a view
      # get 'orders/all', to: 'orders#all'
      resources :orders
    end
  end
```

_Rails_ provides a shortcut for defining _CRUD endpoints_: `ressources` instead of manually defining all these endpoints:

- `GET` /products → products#index (list all products)
- `GET` /products/new → products#new (form for a new product)
- `POST` /products → products#create (create a new product)
- `GET` /products/:id → products#show (show a specific product)
- `GET` /products/:id/edit → products#edit (form to edit a product)
- `PATCH` /products/:id → products#update (update a product)
- `PUT` /products/:id → products#update (update a product)
- `DELETE` /products/:id → products#destroy (delete a product)

Setting up the _controllers_ which also gonna generate _views_ folder, :

```bash
# The flag provided is skipping the config of routes since they already are defined
bin/rails generate controller Products index --skip-routes
bin/rails generate controller Orders index --skip-routes
```

---

<br>

## Adding OPENAPI / SWAGGR docs 📑

[Generating an OpenAPI/Swagger spec from a Ruby on Rails API](https://www.doctave.com/blog/generate-openapi-swagger-spec-from-ruby-on-rails)

Add the following _gems_ to projects `Gemfile`:

```ruby
# OPENAPI / SWAGGER
gem "rswag-api"
gem "rswag-ui"

group :development, :test do
  gem "rspec-rails"   # Note that we also need rspec-rails
  gem "rswag-specs"
end
```

Install the added _gems_ and run the installers for `rswag` and `rspec-rails`:

```bash
# Install gems
bin/bundle install

# Run installers
# rspec-rails
bin/rails generate rspec:install

# rswag
bin/rails g rswag:api:install && ./bin/rails g rswag:ui:install && RAILS_ENV=test ./bin/rails g rswag:specs:install

# Create specs to describe Api one for each controller
# ORDERS
bin/rails generate rspec:swagger Api::Orders
# PRODUCTS
bin/rails generate rspec:swagger Api::Products

# Generate the Swagger docs defined by specs in ./store-support/spec/*
bin/rails rswag:specs:swaggerize
```

[Checkout the spec folder for configuring and enabling the docs](./store-support/spec)

Start the _Rails_ server and checkout the docs -> http://localhost:3000/api-docs/index.html

---

<br>

## Sources

[Creating a REST API wiht Rails](https://medium.com/@oliver.seq/creating-a-rest-api-with-rails-2a07f548e5dc)

[Validation of models with Rails](https://dev.to/daviducolo/rails-model-validation-a-comprehensive-guide-with-code-examples-21mh)

[Service objects Ruby on Rails](https://medium.com/nyc-ruby-on-rails/design-patterns-in-ruby-on-rails-service-objects-a90bf9178689)

[Service objects on Rails - inherits ApplicationService](https://medium.com/@thilorusche/service-objects-for-rails-9c5973dc8bc2)

---

**Instance variables** where interesting -> decided to not use them within _controllers_ since _ERB_ was not used for this API based application.

[Instance variables in Ruby - geeksforgeeks](https://www.geeksforgeeks.org/instance-variables-in-ruby/)

[Instance variables in Ruby - ruby-doc](https://ruby-doc.org/docs/ruby-doc-bundle/UsersGuide/rg/instancevars.html)
