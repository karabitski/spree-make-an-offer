module Spree
  class MakeAnOfferController < ApplicationController

    def create
      case
      when current_user.nil?
        flash[:error] = t('offer_error_not_signed_in')
      when params[:offer_price].to_i == 0
        flash[:error] = t('offer_rejected_validation_0')
      when params[:offer_price] <= params[:offer_previous_price]
        flash[:error] = t('offer_rejected_validation_previous_price')
      else
        if params[:offer_id].to_i == 0 or params[:offer_id].nil?
          @offer = Offer.new(:user_id => current_user.id,
                             :product_id => params[:offer_product_id],
                             :variant_id => params[:offer_variant_id])
        else
          @offer = Offer.find(params[:offer_id])
        end
        @offer.price = params[:offer_price]
        @offer.expires_at = DateTime.now+3.days
        if @offer.save
          OfferMailer.pending(@offer).deliver
          flash[:notice] = t('offer_has_been_submitted')
        else
          binding.pry
          flash[:error] = t('offer_error_not_submitted')
        end
      end
      respond_to do |format|
        format.html { redirect_to '/products/' + params[:offer_permalink] }
      end
    end

  end
end
