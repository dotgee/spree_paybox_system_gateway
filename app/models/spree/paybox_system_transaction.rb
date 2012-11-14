module Spree
  class PayboxSystemTransaction < ActiveRecord::Base
    attr_accessible :action, :amount, :auto, :error, :ref
      
    has_many :payments, :as => :source

    def actions
      []
    end
      
    class << self
      def create_from_postback(params)
        PayboxSystemTransation.create(
          :action => params[:action],
          :amount => params[:amount],
          :auto => params[:auto],
          :error => params[:error],
          :ref => params[:ref]
        )
      end
    end
  end
end
