class CreateProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name
      t.string :category
      t.text :description
      t.string :image_url
      t.decimal :price
      t.integer :stock
      t.boolean :active

      t.timestamps
    end
  end
end
