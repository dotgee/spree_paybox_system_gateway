class Spree::Admin::PayboxSystemGatewaySettingsController < Spree::Admin::BaseController
  def edit
    
  end

  def update
    # workaround for unset checkbox behaviour
    # params[:preferences][:track_locale] = false               if params[:preferences][:track_locale].blank?
    SpreePayboxSystemGateway::Config.set(params[:preferences])

    Payr.setup do |config|
      config.site_id = SpreePayboxSystemGateway::Config.site_id
      config.rang = SpreePayboxSystemGateway::Config.rang
      config.paybox_id = SpreePayboxSystemGateway::Config.paybox_id
      config.secret_key = SpreePayboxSystemGateway::Config.secret_key
      config.paybox_url = SpreePayboxSystemGateway::Config.paybox_url
      # config.paybox_url_back_one = SpreePayboxSystemGateway::Config.paybox_url_back_one unless SpreePayboxSystemGateway::Config.paybox_url_back_one.blank?
      # config.paybox_url_back_two = SpreePayboxSystemGateway::Config.paybox_url_back_two unless SpreePayboxSystemGateway::Config.paybox_url_back_two.blank?
    end

    respond_to do |format|
      format.html do
        redirect_to admin_paybox_system_gateway_settings_path
      end
    end
  end
end
