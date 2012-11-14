Deface::Override.new(:virtual_path => "spree/admin/configurations/index",
                     :name => "add_paybox_system_gateway_to_admin_configuration_menu",
                     :insert_bottom => "[data-hook='admin_configurations_menu'], #admin_configurations_menu[data-hook]",
                     :text => "<%= configurations_menu_item(t('paybox_system_gateway.paybox_system_gateway_settings'), admin_paybox_system_gateway_settings_path, t('spree_paybox_system_gateway.manage_paybox_system_gateway_settings')) %>",
                     :disabled => false)
