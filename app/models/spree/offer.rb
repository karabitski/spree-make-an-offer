module Spree
  class Offer < ActiveRecord::Base

    belongs_to :user
    belongs_to :product
    belongs_to :variant

    attr_accessible :price, :user_id, :product_id, :variant_id, :accepted_at, :rejected_at, :counter_price, :counter_accepted

    validates_presence_of :price
    validates_presence_of :expires_at

    scope :user_offers, lambda { |user_id|
      {:conditions => {:user_id => user_id}}
    }
    scope :product_offers, lambda { |product_id|
      {:conditions => {:product_id => product_id}}
    }
    scope :pending_offers, {:conditions => ["spree_offers.expires_at >= '" + Date.today.to_s(:db) + "'"]}

    def clear_counter_offer
      self.update_attributes counter_price: nil, counter_accepted: nil
    end

  end
end
