module Spree
  class MakeAnOfferController < ApplicationController

    before_filter :auth_user, only: :create

    def create
      # Fix when current_user.nil?
      offer_price = currency_param_to_f(params[:offer_price])

      case
      when offer_price == 0
        flash[:error] = t('offer.offer_rejected_validation_0')
      else
        @offer = Offer.where(id: params[:offer_id], accepted_at: nil, rejected_at: nil).first

        if @offer.blank?
          @offer = Offer.new(user_id: current_user.id, product_id: params[:offer_product_id], variant_id: params[:offer_variant_id])
        else
          @offer.clear_counter_offer
        end

        @offer.price = offer_price
        @offer.expires_at = DateTime.now + offer_expiration_days.days

        if @offer.save
          OfferMailer.pending(@offer).deliver
          flash[:notice] = t('offer.offer_has_been_submitted')
        else
          flash[:error] = t('offer.offer_error_not_submitted')
        end

      end

      respond_to do |format|
        format.html { redirect_to '/products/' + params[:offer_permalink] }
      end
    end

    def accept_counter_offer
      @offer = Offer.update(params[:offer_id].to_i, counter_accepted: DateTime.now)
      OfferMailer.counter_offer_accepted(@offer).deliver
      redirect_to root_path, notice: t('offer.counter_offer_accepted_submited')
    end

    private

    def auth_user
      session["user_return_to"] = request.referer
      redirect_to login_path unless current_user.present?
    end

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
