# Implementing Support Application for an Online Shop 🛍️

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

- Ensure that `rails` is added as _gem_ (check by runing `rails -v`): `rails new store-support`
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
- `category` (enum): e.g., electronics, clothing, books, home, other.
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

#### Seeding DB 🌾

