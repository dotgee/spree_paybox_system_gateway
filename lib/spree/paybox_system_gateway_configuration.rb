class Spree::PayboxSystemGatewayConfiguration < Spree::Preferences::Configuration
  preference :site_id, :integer, :default => 1999888
  preference :rang, :string, :default => '32'
  preference :paybox_id, :integer, :default => 110647233
  preference :secret_key, :string, :default => '0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0123456789ABCDEF'
  preference :hash, :string, :default => 'sha512'
  preference :currency, :string, :default => 'euro'
  preference :paybox_url, :string, :default => "https://preprod-tpeweb.paybox.com/cgi/MYchoix_pagepaiement.cgi"

  preference :paybox_url_back_one, :string, :default => "http://localhost:3000/"
  preference :paybox_url_back_two, :string, :default => nil

  preference :effectue, :string, :default => "http://localhost:3000/"

  preference :callback_values, :hash, :default => { amount:"m", ref:"r", auto:"a", error:"e", signature:"k" }

  preference :typepaiement, :string, :default => nil # CARTE
  preference :typecard, :string, :default => nil # CB
end
