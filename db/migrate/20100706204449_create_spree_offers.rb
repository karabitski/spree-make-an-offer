class CreateSpreeOffers < ActiveRecord::Migration
  def self.up
    create_table :spree_offers do |t|
      t.integer :user_id
      t.integer :store_id
      t.integer :product_id
      t.integer :variant_id
      t.decimal  :price, :precision => 8, :scale => 2, :null => false
      t.datetime :expires_at
      t.datetime :accepted_at
      t.datetime :rejected_at
      t.text :comment
      t.timestamps
    end
    add_index(:spree_offers, :id)
    add_index(:spree_offers, :user_id)
    add_index(:spree_offers, :product_id)
    add_index(:spree_offers, :expires_at)
  end

  def self.down
    drop_table :spree_offers
  end
end
