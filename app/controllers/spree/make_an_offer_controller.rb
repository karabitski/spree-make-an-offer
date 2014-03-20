module Spree
  class MakeAnOfferController < ApplicationController

    def create
      # Fix when current_user.nil?
      offer_price = currency_param_to_f(params[:offer_price])

      case
      when offer_price == 0
        flash[:error] = t('offer_rejected_validation_0')
      else
        if params[:offer_id].to_i == 0 || params[:offer_id].nil?
          @offer = Offer.new(:user_id => current_user.id,
                             :product_id => params[:offer_product_id],
                             :variant_id => params[:offer_variant_id])
        else
          @offer = Offer.find(params[:offer_id])
        end

        @offer.price = offer_price
        @offer.expires_at = DateTime.now+3.days

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

  end
end
