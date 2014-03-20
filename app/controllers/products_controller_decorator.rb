Spree::ProductsController.class_eval do
  before_filter :before_show, :only => [:show]
  helper :make_an_offer

  def before_show
    @product = Spree::Product.find_by_permalink!(params[:id])

    if current_user.present?
      @offer = Spree::Offer.user_offers(current_user.id).product_offers(@product.id).pending_offers.last # TODO: Get offer with max price
    end

    @previous = Spree::Offer.find(:first, :order => 'price DESC', :conditions => {:product_id => @product.id})

    if @offer == nil
      @offer = Spree::Offer.new(:price => 0.00)
      @offer_expires_at = (Date.today + 5).strftime('%m/%d/%Y')
    else
      # named_scopes returns :all, select :first
      @offer_expires_at = @offer.expires_at.strftime('%m/%d/%Y')
    end

    @offer_price = Spree::Money.new(@offer.price, no_currency: true).to_s
  end

end
