#
#encoding: utf-8
#
module Spree
  CheckoutController.class_eval do
    before_filter :paybox_check_response, :only => [ :paybox_paid, :paybox_refused, :paybox_cancelled ]
    before_filter :paybox_check_ipn_response, :only => [ :paybox_ipn ]

    before_filter :load_paybox_params, :only => [ :paybox_pay ]
    before_filter :validate_paybox, :except => [ :edit ]

    #
    # Very bad hack to handle paybox external payment from
    # standard checkout process
    #
    def update_with_paybox
      if params[:order][:payments_attributes].present?
        p_id =  params[:order][:payments_attributes].first[:payment_method_id]
        unless p_id.nil?
          if PaymentMethod.find(p_id).class == Spree::PaymentMethod::PayboxSystem
            redirect_to :action => :paybox_pay, :params => { :payment_method_id => p_id } and return
          end
        end
      end
      update_without_paybox
    end
    alias_method_chain :update, :paybox

    def paybox_pay
      unless @order.payments.where(:source_type => 'Spree::PayboxSystemTransaction').present?
        #
        # Record used payment method before payment
        # because there is no way to pass additionnal params
        # to paybox system
        #
        payment_method = PaymentMethod.find(params[:payment_method_id])
        payment = @order.payments.create(:amount => @order.total,
                                         # :source => paybox_transaction,
                                         :payment_method_id => payment_method.id)
        render action: 'paybox_pay', layout: false
      end
    end

    def paybox_paid
      # order_id, payment_method_id = params[:ref].split('|')

      unless @order.payments.where(:source_type => 'Spree::PayboxSystemTransaction').present?
        payment_method = @order.payment_method # PaymentMethod.find(payment_method_id)
        paybox_transaction = Spree::PayboxSystemTransaction.create_from_postback params.merge(:action => 'paid') # new(:action => 'paid', :amount => params[:amount], :auto => params[:auto], :error => params[:error], :ref => order_id)

        payment = @order.payments.where(:state => 'checkout',
                                        :payment_method_id => payment_method.id).first

        if payment
          payment.source = paybox_transaction
          payment.save
        else
          payment = @order.payments.create(:amount => @order.total,
                                           :source => paybox_transaction,
                                           :payment_method_id => payment_method.id)
        end

        payment.started_processing!
        unless payment.completed?
         # see: app/controllers/spree/skrill_status_controller.rb line 22
         payment.complete!
        end
      end

      until @order.state == 'complete'
        if @order.next!
          @order.update!
          state_callback(:after)
        end
      end

      logger.debug "PAYBOX_PAID: #{payment_method.inspect} #{@order.payments.inspect} #{@order.inspect} #{params.inspect}"

      flash.notice = t(:order_processed_successfully)
      redirect_to completion_route
    end

    def paybox_refused
      flash[:error] = "Opération refusée"
      redirect_to "/checkout/payment"
    end

    def paybox_cancelled
      flash[:error] = "Opération annulée"
      redirect_to "/checkout/payment"
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

        @paybox_params = @payr.get_paybox_params_from command_id: @order.id,
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
