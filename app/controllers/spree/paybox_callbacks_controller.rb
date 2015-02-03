class Spree::PayboxCallbacksController < Payr::BillsController
  before_filter :authenticate_user!, except: [:ipn]
  skip_before_filter :check_ipn_response
  NO_ERROR = "00000"

  def ipn
    #super
    @order = Spree::Order.find(params[:ref])
    if params[:error] == NO_ERROR #&& Payr::Client.new.check_response_ipn(request.url)
      unless @order.payments.where(:source_type => 'Spree::PayboxSystemTransaction').present?
        set_payment
        paybox_transaction = Spree::PayboxSystemTransaction.create_from_postback params.merge(:action => 'paid')
        if @payment
          @payment.source = paybox_transaction
          @payment.save
        else
          @payment = @order.payments.create(:amount => @order.total,
                                           :source => paybox_transaction,
                                           :payment_method_id => @payment_method.id)
        end

        @payment.started_processing!
        unless @payment.completed?
          @payment.update_attributes(state: "checkout", response_code: "")
          # see: app/controllers/spree/skrill_status_controller.rb line 22
          @payment.complete!
        end
      end

      @order.finalize!
      logger.debug "PAYBOX_PAID: #{@payment_method.inspect} #{@order.payments.inspect} #{@order.inspect} #{params.inspect}"
    else
      set_payment
      @payment.update_attributes(state: "invalid", response_code: params[:error]) if @payment
      logger.debug "Erreur: #{params[:error]}"
    end
    render nothing: true, :status => 200, :content_type => 'text/html'
  end

  def set_payment
    @payment_method = Spree::PaymentMethod.where(type: "Spree::PaymentMethod::PayboxSystem").first
    @payment = @order.payments.where(:state => 'checkout',
                                        :payment_method_id => @payment_method.id).first
  end
end
