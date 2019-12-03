module Transactionable
  extend ActiveSupport::Concern

  included do
    has_many :transactions, as: :owner
    before_destroy :create_destroy_transaction
  end

  def create_transaction(action: 'Create', context: nil)
    if !self.changes()['viewer_access'].present? &&
      ((!self.respond_to?(:completed)) || (self.respond_to?(:completed) && self.completed?))
      Transaction.build_for(
        self,
        action,
        defined?(session) ? (session[:simulated_id] || session[:user_id]) : nil,
        context || (defined?(session) ? '' : "Recurring #{self.class.name.titleize}"),
        nil,
        nil,
        defined?(session) ? session[:platform] : 'System'
      )
    end
  end


  def create_owner_transaction(action:nil)
    Transaction.build_for(
      self.owner,
      action || "Add #{self.class.name.titleize}",
      ((session[:simulated_id] || session[:user_id]) rescue nil),
      "##{self.get_id} #{self.title}"
    )
  end

  def create_destroy_transaction
    Transaction.build_for(
      self,
      'Destroy',
      defined?(session) ? session[:user_id] : nil,
      "Deleted by: #{defined?(session) ?  User.find(session[:user_id]).full_name : 'N/A'}"
    )
  end

end
