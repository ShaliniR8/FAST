namespace :safety_reporting do

  desc "Update historical anonymous transactions."
  task :update_anonymous_transactions => :environment do


    submitter_actions = ['Create', 'Add Attachment', 'Dual Report', 'Add Notes']

    transactions = Submission.where(anonymous: 1)
      .map(&:transactions)
      .flatten
      .select{|transaction| submitter_actions.include? transaction.action}

    transactions += Record.where(anonymous: 1)
      .map(&:transactions)
      .flatten
      .select{|transaction| submitter_actions.include? transaction.action}

   transactions.map{|transaction| transaction.update_attributes({users_id: nil})}


  end

end

