Spree::Core::Engine.routes.prepend do

  resources :make_an_offer, :only => :create

  namespace :admin do
    resources :offers
  end

  match '/accept-counter-offer/:offer_id' => 'make_an_offer#accept_counter_offer', as: :accept_counter_offer
  match 'admin/offers/counter_offer/:offer_id' => 'admin/offers#counter_offer', :as => :counter_offer_admin_offers
  match 'admin/offers/accepted/:offer_id' => 'admin/offers#accepted', :as => :accepted_admin_offers
  match 'admin/offers/rejected/:offer_id' => 'admin/offers#rejected', :as => :rejected_admin_offers

end
