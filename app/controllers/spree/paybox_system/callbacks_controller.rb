class Spree::PayboxSystem::CallbacksController < Payr::BillsController
  # if you use cancan
  ### skip_authorization_check
  # if you use devise 
  ### before_filter :authenticate_buyer!
  ### layout "simply_blue_simple"

  # But you can also rewrite the actions
  # to redirect to a specific action, for example :
  def paid
    super
    bill = Payr::Bill.find params[:ref]
    raise "#{params.inspect} #{bill.inspect}"
    #pack = Pack.find bill.article_id
    #current_buyer.add_pack pack
    #redirect_to new_offer_path
  end

  def pay
    super
  end

  def refused
  end

  def cancelled
    super
    redirect_to '/'
  end

  def ipn
  end
end
