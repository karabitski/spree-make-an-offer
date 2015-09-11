Spree::Core::Engine.add_routes do

  resources :make_an_offer, only: :create

  namespace :admin do
    resources :offers
  end

  get '/accept-counter-offer/:offer_id', to: 'make_an_offer#accept_counter_offer', as: :accept_counter_offer
  get 'admin/offers/counter_offer/:offer_id', to: 'admin/offers#counter_offer', as: :counter_offer_admin_offers
  get 'admin/offers/accepted/:offer_id', to: 'admin/offers#accepted', as: :accepted_admin_offers
  get 'admin/offers/rejected/:offer_id', to: 'admin/offers#rejected', as: :rejected_admin_offers

end
