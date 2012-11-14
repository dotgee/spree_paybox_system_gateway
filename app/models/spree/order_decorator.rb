# Spree::Order.state_machine.before_transition :from => :payment,
#                                            :do   => :check_paybox?

Spree::Order.class_eval do
  state_machine do
    before_transition any => any do |order, transition|
      raise "Transition: #{transition.inspect}" unless [ 'address', 'delivery' ].include? transition.from
      Spree::Order.logger.debug "Transition: #{transition.inspect}"
    end
  end

  def check_paybox?
    raise payments.inspect
  end
end
