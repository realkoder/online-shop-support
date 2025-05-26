class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :fullname
      t.string :email
      t.string :phone
      t.string :image_url

      t.timestamps
    end
  end
end
