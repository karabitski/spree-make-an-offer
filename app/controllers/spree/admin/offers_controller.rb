# coding: utf-8
module Spree
  module Admin
    class OffersController < ResourceController

      def index
        @offers = spree_current_store.offers.pending_offers.order('spree_offers.created_at, spree_offers.product_id').page(params[:page])
      end

      def counter_offer
        @offer = spree_current_store.offers.find(params[:offer_id])
        @offer.update_attributes(counter_price: currency_param_to_f(params[:counter_price]))
        @offer.user.notify("Counter offer issued", render_to_string('offer_mailer/counter_offer.txt.erb'))
        # OfferMailer.counter_offer(@offer).deliver
        redirect_to admin_offers_path, notice: t('counter_offer_sent')
      end

      def accepted
        @offer = spree_current_store.offers.find(params[:offer_id])
        if @offer.update_attributes(accepted_at: Date.today, rejected_at: nil)
          @offer.user.notify("Offer accepted", render_to_string('offer_mailer/accepted.txt.erb'))
          # OfferMailer.accepted(@offer).deliver
          redirect_to admin_offers_url
        else
          redirect_to admin_offers_url, error: 'Error occured'
        end
      end

      def rejected
        @offer = spree_current_store.offers.find(params[:offer_id])
        @offer.update_attributes(rejected_at: Date.today, accepted_at: nil)
        @offer.user.notify("Offer rejected", render_to_string('offer_mailer/rejected.txt.erb'))
        # OfferMailer.rejected(@offer).deliver
        redirect_to admin_offers_url
      end

      private

      def currency_param_to_f(string)
        string.gsub(',', '.').to_f
      end

    end
  end
end
