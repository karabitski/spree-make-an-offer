module Spree
  class MakeAnOfferController < ApplicationController

    def create
      unless spree_current_user
        render_error "You must log in to make an offer." and return
      end
      # Fix when current_user.nil?
      offer_price = currency_param_to_f(params[:offer_price])

      case
      when offer_price == 0
        render_error t('offer_rejected_validation_0')
        return
      when offer_price <= params[:offer_previous_price].to_i
        render_error "Your offer is lower than highest offer price. Please make an offer higher than $#{params[:offer_previous_price]}"
        return
      else
        @offer = Offer.where(id: params[:offer_id], accepted_at: nil, rejected_at: nil).first

        if @offer.blank?
          product = Spree::Product.find(params[:offer_product_id])
          @offer = Offer.new(user_id: spree_current_user.id,
                             store_id: product.store_id,
                             product_id: product.id,
                             variant_id: params[:offer_variant_id])
          new_record = true
        else
          @offer.clear_counter_offer
        end

        @offer.price = offer_price
        @offer.expires_at = DateTime.now + offer_expiration_days.days

        if @offer.save
          increment_offer_count if new_record
          @offer.store.owner.notify("Offer pending", render_to_string('offer_mailer/pending.txt.erb'))
          # OfferMailer.pending(@offer).deliver
          send_message if params[:message].present?
          flash[:notice] = "Your offer has been sent and will be reviewed shortly!"
        else
          if @offer.errors.any?
            render_error @offer.errors.messages.values.flatten.join
            return
          else
            render_error t('offer_error_not_submitted')
            return
          end
        end
      end
      respond_to do |format|
        format.json { render json: { success: true, message: flash[:notice] } }
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

    def render_error(message)
      respond_to do |format|
        format.json { render json: { success: false, message: message } }
        format.html
      end
    end

    def send_message
      return if fail_if_no_user
    	@recipient = @offer.product.owner

    	@receipt = spree_current_user.send_message @recipient, params[:message], "New #{@offer.product.name} offer"
      if @receipt.errors.blank?
        spree_current_user.create_activity :new_message
      else
        @receipt.errors.full_messages.join('. ')
      end
    end

    def fail_if_no_user
  		no_user = !spree_current_user
  		respond_to do |format|
  			format.json do
  				render json: { success: false, errors: "You must login in to send a message." } if no_user
  			end
  		end
  		no_user
  	end

    def increment_offer_count
      Spree::Product.increment_counter(:offer_count, @offer.product_id)
    end

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
