module SpreePayboxSystemGateway
  class Engine < Rails::Engine
    require 'spree/core'
    require 'payr'
    isolate_namespace Spree
    engine_name 'spree_paybox_system_gateway'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'spree.paybox_system_gateway.preferences', :after => 'spree.environment' do |app|
      SpreePayboxSystemGateway::Config = Spree::PayboxSystemGatewayConfiguration.new
    end

    initializer 'spree.paybox_system_gateway.init_payr', :after => 'spree.paybox_system_gateway.preferences' do |app|
      SpreePayboxSystemGateway.init_paybox
    end

     initializer "paybox_system_gateway.register.payment_methods", :after => 'spree.register.payment_methods' do |app|
      app.config.spree.payment_methods += [
        Spree::PaymentMethod::PayboxSystem
      ]
    end

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end

  #
  # Initialize paybox Payr module with preferences values
  # This method take place here because of loading order (preference then payr)
  #
  def self.init_paybox
    Payr.setup do |config|
	    # Put the  merchant site ID found on the paybox website
	    #config.site_id = 1999888
	    config.site_id = Config.site_id

	    # Put the merchant rang found on the paybox website
	    #config.rang = 32
	    config.rang = Config.rang
	
	    # Put the merchant paybox ID found on the paybox website
	    #config.paybox_id = 1686319
	    config.paybox_id = Config.paybox_id
	    # config.paybox_id = 7293139
	
	    # Put the secret key for the hmac pass found on the paybox website
	    config.secret_key = Config.secret_key

	    # Put the hash algorithm
	    # Possible values are :SHA256 :SHA512 :SHA384 :SHA224 
	    config.hash = :sha512
	
	    # The currency 
	    # possible values :euro :us_dollar
	    config.currency = :euro 
	
	    config.paybox_url = Config.paybox_url
	    # config.paybox_url = "https://preprod-tpeweb.paybox.com/cgi/MYframepagepaiement_ip.cgi"
	    config.paybox_url_back_one = Config.paybox_url_back_one
	    config.paybox_url_back_two = Config.paybox_url_back_two

	    config.callback_values = { amount:"m", ref:"r", auto:"a", error:"e", signature:"k" }

	    # Optionnal config : if not null, choose on behalf of the user the type of paiement. 
	    # EX: "CARTE". Look at the paybox documentation for more
	    #config.typepaiement = "CARTE"
	
	    # Optionnal config : if not null, choose on behalf of the user the type of CARD. 
	    # EX: "CB". Look at the paybox documentation for more
	    #config.typecard = "CB"
    end
  end
end
