Spree::Core::Engine.routes.draw do
  # Add your extension routes here

  # payr_routes callback_controller: "spree/paybox_system/callbacks"

  # resources :orders do
    resource :checkout, :controller => 'checkout' do
      # member do
      collection do
        get :paybox_pay
        get :paybox_paid
        get :paybox_refused
        get :paybox_cancelled
        get :paybox_ipn
      end
    end
  # end

  namespace :admin do
    resource :paybox_system_gateway_settings
  end
end
