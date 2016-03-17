module Spree
  class MakeAnOfferController < ApplicationController

    before_filter :auth_user, only: :create

    def create
      redirect_to root_path, alert: t('offer_module_disabled') and return unless (Spree::Config.offer_module.present? && Spree::Config.offer_module)

      # Fix when current_user.nil?
      offer_price = currency_param_to_f(params[:offer_price])

      case
      when offer_price == 0
        flash[:error] = t('offer_rejected_validation_0')
        redirect_to :back and return
      else
        @offer = Offer.where(id: params[:offer_id], accepted_at: nil, rejected_at: nil).first

        if @offer.blank?
          product = Spree::Product.find(params[:offer_product_id])
          @offer = Offer.new(user_id: spree_current_user.id,
                             store_id: product.store_id,
                             product_id: product.id,
                             variant_id: params[:offer_variant_id])
        else
          @offer.clear_counter_offer
        end

        @offer.price = offer_price
        @offer.expires_at = DateTime.now + offer_expiration_days.days

        if @offer.save
          @offer.store.owner.notify("Offer pending", render_to_string('offer_mailer/pending.txt.erb'))
          # OfferMailer.pending(@offer).deliver
          flash[:notice] = t('offer_has_been_submitted')
        else
          if @offer.errors.any?
            flash[:error] = @offer.errors.messages.values.flatten.join
          else
            flash[:error] = t('offer_error_not_submitted')
          end
        end

      end

      respond_to do |format|
        format.html { redirect_to product_path @offer.product }
      end
    end

    def accept_counter_offer
      @offer = spree_current_user.offers.find(params[:offer_id].to_i)
      @offer.update_attributes(counter_accepted: DateTime.now)
      @offer.store.owner.notify("Counter offer accepted", render_to_string('offer_mailer/counter_offer_accepted.txt.erb'))
      # OfferMailer.counter_offer_accepted(@offer).deliver
      redirect_to product_path(@offer.product), notice: t('counter_offer_accepted_submited')
    end

    private

    def auth_user
      session["spree_user_return_to"] = request.referer
      redirect_to login_path unless spree_current_user.present?
    end

    def currency_param_to_f(string)
      string.gsub(',', '.').to_f
    end

    def offer_expiration_days
      if Spree::Config.offer_expiration.present?
        Spree::Config.offer_expiration.to_i
      else
        3
      end
    end

  end
end
