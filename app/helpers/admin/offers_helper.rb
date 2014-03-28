module Admin::OffersHelper
  def offer_status(offer)
    case
    when !offer.product.has_stock?
      t("offer.out_of_stock")
    when !offer.rejected_at.nil?
      t("offer.rejected") + " " + offer.rejected_at.strftime("%m/%d/%Y")
    when !offer.accepted_at.nil?
      t("offer.accepted") + " " + offer.accepted_at.strftime("%m/%d/%Y")
    else
      link_to_with_icon('accept', t("offer.accept"), accepted_admin_offers_path(offer.id)) + ' | ' + link_to_with_icon('delete', t("offer.reject"), rejected_admin_offers_path(offer.id))
    end
  end
end
