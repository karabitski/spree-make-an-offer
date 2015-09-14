module Spree
  class Offer < ActiveRecord::Base

    belongs_to :user
    belongs_to :product
    belongs_to :variant
    belongs_to :store

    validates_presence_of :price
    validates_presence_of :expires_at
    validate :minimum_offer_price

    scope :user_offers, ->(user_id) { where(user_id: user_id) }
    scope :product_offers, ->(product_id) { where(product_id: product_id) }
    scope :pending_offers, ->(){ where("spree_offers.expires_at >= ?", Date.today.to_s(:db))}

    def clear_counter_offer
      self.update_attributes counter_price: nil, counter_accepted: nil
    end

    def minimum_offer_price
      variant_price_with_currency = Spree::Money.new(self.variant.price, symbol: false, decimal_mark: '.', thousands_separator: ',').to_s.delete(',').to_f
      minimum_price = (variant_price_with_currency * (offer_minimum_price_percent * 0.01)).round(2)
      errors.add(:price, I18n.t('offer_error_low_price')) if self.price < minimum_price
    end

    private

    def offer_minimum_price_percent
      if Spree::Config.offer_minimum_price_percent.present?
        Spree::Config.offer_minimum_price_percent.to_i
      else
        85
      end
    end

  end
end
