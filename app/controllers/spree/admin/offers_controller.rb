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

        redirect_to admin_offers_path, notice: t('offer.counter_offer_sent')
      end

      def accepted
        @offer = Offer.update(params[:offer_id], :accepted_at => Date.today)

        if @offer.user.orders.incomplete.size > 1
          @order = @offer.user.orders.incomplete.last
        else
          @order = @offer.user.orders.incomplete.first
        end

        if @order.nil?
          @order = @offer.user.orders.create
        else
          @order.empty!
          @order.save
        end

        @order.add_variant(@offer.variant)
        @order.adjustments.create amount: (@offer.price - @order.total), label: "Desconto por oferta do dia #{@offer.created_at.strftime('%d/%m/%y às %H:%m')}"

        if @order.save
          OfferMailer.accepted(@offer, @order).deliver
          redirect_to admin_offers_url
        else
          redirect_to admin_offers_url, error: 'Erro ao salvar o pedido.'
        end
      end

      def rejected
        @offer = Offer.update(params[:offer_id], :rejected_at => Date.today)
        OfferMailer.rejected(@offer).deliver
        redirect_to admin_offers_url
      end

      private

      def currency_param_to_f(string)
        string.gsub('.', '').gsub(',', '.').to_f
      end

    end
  end
end
