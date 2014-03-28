class OfferMailer < ActionMailer::Base
  helper "spree/base"

  def pending(offer)
    @offer = offer
    subject = "#{Spree::Config[:site_name]} #{t('offer.email.pending.subject')} - #{offer.product.name}"
    mail(:to => Spree::MailMethod.first.preferred_smtp_username, :subject => subject)
  end

  def rejected(offer)
    @offer = offer
    subject = "#{Spree::Config[:site_name]} #{t('offer.email.rejected.subject')} - #{offer.product.name}"
    mail(:to => @offer.user.email, :subject => subject)
  end

  def accepted(offer, order)
    @offer = offer
    @order = order
    subject = "#{Spree::Config[:site_name]} #{t('offer.email.accepted.subject')} - #{offer.product.name}"
    mail(:to => @offer.user.email, :subject => subject)
  end
end
