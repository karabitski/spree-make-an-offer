Spree::ProductsController.class_eval do
  before_filter :before_show, :only => [:show]
  helper :make_an_offer

  def before_show
    @product = Spree::Product.friendly.find params[:id]
    if spree_current_user.present?
      @offer = Spree::Offer.user_offers(spree_current_user.id).product_offers(@product.id).pending_offers.last # TODO: Get offer with max price
    end
    @previous = @product.offers.order('price DESC').first

    if @offer == nil
      @offer = Spree::Offer.new(:price => 0.00)
      @offer_expires_at = (Date.today + 3).strftime('%m/%d/%Y')
    else
      @offer_expires_at = @offer.expires_at.strftime('%m/%d/%Y')
    end
    @offer_price = Spree::Money.new(@offer.price_accepted, no_currency: true).to_s

  end

end
