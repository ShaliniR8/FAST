module Transactionable
  extend ActiveSupport::Concern

  included do
    has_many :transactions, as: :owner,  dependent: :destroy
  end

  def create_transaction(action)
    if !self.changes()['viewer_access'].present?
      Transaction.build_for(
        self,
        action,
        ((session[:simulated_id] || session[:user_id]) rescue nil),
        (defined?(session) ? '' : "Recurring #{self.class.name.titleize}"))
    end
  end

end
