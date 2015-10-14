# coding: utf-8
module Spree
  module Admin
    class OffersController < ResourceController

      def index
        @offers = Offer.pending_offers.order('spree_offers.created_at, spree_offers.product_id').page(params[:page])
      end

      def counter_offer
        @offer = Offer.update(params[:offer_id], counter_price: currency_param_to_f(params[:counter_price]))
        OfferMailer.counter_offer(@offer).deliver

        redirect_to admin_offers_path, notice: t('counter_offer_sent')
      end

      def accepted
        @offer = Offer.update(params[:offer_id], accepted_at: Date.today, rejected_at: nil)

        # if @offer.user.orders.incomplete.size > 1
        #   @order = @offer.user.orders.incomplete.last
        # else
        #   @order = @offer.user.orders.incomplete.first
        # end

        # if @order.nil?
        #   @order = @offer.user.orders.create
        # else
        #   @order.empty!
        #   @order.save
        # end

        # @order.add_variant(@offer.variant)
        # @order.adjustments.create amount: (@offer.price - @order.total), label: "Discount created at #{@offer.created_at.strftime('%d/%m/%y %H:%m')}"

        # if @order.save
        if @offer
          OfferMailer.accepted(@offer).deliver
          redirect_to admin_offers_url
        else
          redirect_to admin_offers_url, error: 'Error occured'
        end
      end

      def rejected
        @offer = Offer.update(params[:offer_id], rejected_at: Date.today, accepted_at: nil)
        OfferMailer.rejected(@offer).deliver
        redirect_to admin_offers_url
      end

      private

      def currency_param_to_f(string)
        string.gsub(',', '.').to_f
      end

    end
  end
end
