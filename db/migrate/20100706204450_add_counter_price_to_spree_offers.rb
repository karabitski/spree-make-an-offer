class AddCounterPriceToSpreeOffers < ActiveRecord::Migration
  def change
    add_column :spree_offers, :counter_price, :decimal
  end
end
