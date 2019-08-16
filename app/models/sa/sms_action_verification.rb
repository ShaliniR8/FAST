class SmsActionVerification < Verification

  belongs_to :owner, foreign_key: :owner_id, class_name: 'SmsAction'


  def create_transaction
    puts "create transaction for CAR - TODO"
  end


end
