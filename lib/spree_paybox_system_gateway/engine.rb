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
end
