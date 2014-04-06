class AddCounterAcceptedToSpreeOffers < ActiveRecord::Migration
  def change
    add_column :spree_offers, :counter_accepted, :datetime
  end
end
