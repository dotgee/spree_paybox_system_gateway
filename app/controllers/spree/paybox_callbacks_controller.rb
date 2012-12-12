class Spree::PayboxCallbacksController < Payr::BillsController
  def ipn
    super
    raise params.inspect
  end
end
