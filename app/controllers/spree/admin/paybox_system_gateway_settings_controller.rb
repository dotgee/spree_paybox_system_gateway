class Spree::Admin::PayboxSystemGatewaySettingsController < Spree::Admin::BaseController
  def edit
    
  end

  def update
    # workaround for unset checkbox behaviour
    # params[:preferences][:track_locale] = false               if params[:preferences][:track_locale].blank?
    SpreePayboxSystemGateway::Config.set(params[:preferences])

    respond_to do |format|
      format.html do
        redirect_to admin_paybox_system_gateway_settings_path
      end
    end
  end
end
