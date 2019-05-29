class SmsActionNotification < Notification

  belongs_to :owner, foreign_key: :owner_id, class_name: 'SmsAction'


  def create_transaction
    @table = "Transaction"
    Transaction.build_for(
      self.owner.id,
      "Set Alert",
      session[:user_id],
      "Recipients: #{users_id.split(',').map{|id| User.find(id).full_name}.join(', ')}.
        Date: #{notify_date}."
      )
  end

end
