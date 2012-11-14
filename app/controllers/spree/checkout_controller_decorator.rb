module Spree
  CheckoutController.class_eval do
    before_filter :paybox_check_response, :only => [ :paybox_paid, :paybox_refused, :paybox_cancelled ]
    before_filter :paybox_check_ipn_response, :only => [ :paybox_ipn ]

    before_filter :load_paybox_params, :only => [ :paybox_pay ]
    before_filter :validate_paybox, :except => [ :edit ]

    def paybox_pay
    end

    def paybox_paid
      order_id, payment_method_id = params[:ref].split('|')

      unless @order.payments.where(:source_type => 'Spree::PayboxSystemTransaction').present?
        payment_method = PaymentMethod.find(payment_method_id)
        paybox_transaction = PayboxSystemTransaction.new(:action => 'paid', :amount => params[:amount], :auto => params[:auto], :error => params[:error], :ref => order_id)

        payment = @order.payments.create(:amount => @order.total,
                                         :source => paybox_transaction,
                                         :payment_method_id => payment_method.id)

        payment.started_processing!
        payment.pend!

      end

      until @order.state == 'complete'
        if @order.next!
          @order.update!
          state_callback(:after)
        end
      end

      logger.debug "PAYBOX_PAID: #{order_id} #{payment_method.inspect} #{@order.payments.inspect} #{@order.inspect} #{params.inspect}"

      flash.notice = t(:order_processed_sucessfully)
      redirect_to completion_route
    end

    def paybox_refused
      raise "PAYBOX_REFUSED: #{params.inspect}"
    end

    def paybox_cancelled
      raise "PAYBOX_CANCELLED: #{params.inspect}"
    end

    def paybox_ipn
      raise "PAYBOX_IPN: #{params.inspect}"
    end

    private
      def paybox_check_response
        unless Payr::Client.new.check_response(request.url)
          raise "Bad paybox sign response"
          # redirect to failure
          return
        end
      end

      def paybox_check_ipn_response
        unless Payr::Client.new.check_response(request.url)
          raise "Bad paybox sign response"
          # redirect to failure
          return
        end
      end

      def load_paybox_params
        # return unless params[:state] == 'payment'

        @payr = Payr::Client.new

        @paybox_params = @payr.get_paybox_params_from command_id: [ @order.id, params[:payment_method_id] ].join('|'),
                                                      buyer_email: current_user.email,
                                                      total_price: ( @order.total * 100 ).to_i,
                                                      callbacks: {
                                                        # paid: "http://paybox.devel.dotgee.fr:3000/checkout/paybox_paid",
                                                        # refused: "http://paybox.devel.dotgee.fr:3000/checkout/paybox_paid",
                                                        # cancelled: "http://paybox.devel.dotgee.fr:3000/checkout/paybox_paid",
                                                        # ipn: "http://paybox.devel.dotgee.fr:3000/checkout/paybox_paid"
                                                        paid: paybox_paid_checkout_url,
                                                        refused: paybox_refused_checkout_url,
                                                        cancelled: paybox_cancelled_checkout_url,
                                                        ipn: paybox_ipn_checkout_url
                                                      }
    
      
      end


      def validate_paybox
        return if [ 'address', 'delivery' ].include?(params[:state])
        # raise params.inspect
      end
  end
end
