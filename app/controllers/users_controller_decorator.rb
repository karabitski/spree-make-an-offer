Spree::UsersController.class_eval do

  before_filter :before_show, :only => [:show]

  def before_show
    @offers = Spree::Offer.user_offers(@user.id).pending_offers.includes(:product)
  end
end
