module Spree
  class MakeAnOfferController < ApplicationController

    def create
      # Fix when current_user.nil?
      offer_price = currency_param_to_f(params[:offer_price])

      case
      when offer_price == 0
        flash[:error] = t('offer_rejected_validation_0')
      else
        @offer = Offer.where(id: params[:offer_id], accepted_at: nil, rejected_at: nil).first

        if @offer.blank?
          @offer = Offer.new(user_id: current_user.id, product_id: params[:offer_product_id], variant_id: params[:offer_variant_id])
        end

        @offer.price = offer_price
        @offer.expires_at = DateTime.now + offer_expiration_days.days

        if @offer.save
          OfferMailer.pending(@offer).deliver
          flash[:notice] = t('offer_has_been_submitted')
        else
          flash[:error] = t('offer_error_not_submitted')
        end

      end

      respond_to do |format|
        format.html { redirect_to '/products/' + params[:offer_permalink] }
      end
    end

    private

    def currency_param_to_f(string)
      string.gsub('.', '').gsub(',', '.').to_f
    end

    def offer_expiration_days
      if Spree::Config.offer_expiration.present?
        Spree::Config.offer_expiration.to_i
      else
        5
      end
    end

  end
end
