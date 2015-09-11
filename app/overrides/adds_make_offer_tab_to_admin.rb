Deface::Override.new(:virtual_path  => "spree/products/show",
                     :name          => "add_offer_form_to_product_show",
                     :insert_bottom => "[data-hook='cart_form']",
                     :partial       => "products/offers")

Deface::Override.new(:virtual_path  => "spree/users/show",
                     :name          => "add_user_offers_to_users_show",
                     :insert_bottom => "[data-hook='account_my_orders']",
                     :partial       => "users/my_offers")

Deface::Override.new(:virtual_path  => "spree/layouts/admin",
                     :name          => "add_offers_tab_to_admin_layout",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :partial       => "spree/admin/offers/menu_link")
