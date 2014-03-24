# coding: utf-8
module MakeAnOfferHelper
  def offer_status(offer)
    case
    when offer.rejected_at.present?
      content_tag(:span, t(:offer_rejected, date: offer.rejected_at.strftime('%d/%m/%y às %H:%m')), class: 'state canceled')
    when offer.accepted_at.present?
      content_tag(:span, t(:offer_accepted, date: offer.accepted_at.strftime('%d/%m/%y às %H:%m')), class: 'state complete')
    else
      content_tag(:span, t(:offer_created, date: offer.created_at.strftime('%d/%m/%y às %H:%m')), class: 'state pending')
    end
  end
end
