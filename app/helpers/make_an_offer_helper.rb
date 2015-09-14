# coding: utf-8
module MakeAnOfferHelper
  def offer_status(offer)
    case
    when offer.rejected_at.present?
      content_tag(:span, t('offer_rejected', date: offer.rejected_at.strftime('%d/%m/%y %H:%m')), class: 'state canceled')
    when offer.accepted_at.present?
      content_tag(:span, t('offer_accepted', date: offer.accepted_at.strftime('%d/%m/%y %H:%m')), class: 'state complete')
    when offer.counter_price.present? && offer.counter_accepted.nil?
      content_tag(:span, t('counter_offered', date: offer.updated_at.strftime('%d/%m/%y %H:%m')), class: 'state pending')
    when offer.counter_price.present? && offer.counter_accepted.present?
      content_tag(:span, t('counter_offer_accepted', date: offer.counter_accepted.strftime('%d/%m/%y %H:%m')), class: 'state complete')
    else
      content_tag(:span, t('offer_created', date: offer.created_at.strftime('%d/%m/%y %H:%m')), class: 'state pending')
    end
  end

  def previous_price
    if @previous.present?
      "<p>#{t('previous_high_offer')} <span class=\"price selling\">#{Spree::Money.new(@previous.price, no_currency: true)}</span></p>".html_safe
    end
  end
end
