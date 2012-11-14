Deface::Override.new(:virtual_path => "spree/admin/shared/_configuration_menu",
                     :name => "add_paybox_system_gateway_to_admin_configuration_sidebar",
                     :insert_bottom => "[data-hook='admin_configurations_sidebar_menu'], #admin_configurations_sidebar_menu[data-hook]",
                     :text => "<%= configurations_sidebar_menu_item t('spree_paybox_system_gateway.paybox_system_gateway_settings'), admin_paybox_system_gateway_settings_path %>",
                     :disabled => false)
