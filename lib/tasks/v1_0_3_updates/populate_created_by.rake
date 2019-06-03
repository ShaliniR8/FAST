namespace :version_1_0_3 do


  task :populate_created_by => :environment do

    transaction_types = [
      "CorrectiveActionTransaction",
      "SraTransaction",
      "HazardTransaction",
      "RiskControlTransaction",
      "AuditTransaction",
      "InspectionTransaction",
      "EvaluationTransaction",
      "InvestigationTransaction",
      "FindingTransaction",
      "RecommendationTransaction",
      "SmsActionTransaction"
    ]

    transactions = Transaction.where(:action => 'Create', :type => transaction_types)

    transactions.each do |x|
      t_type = x.type
      t_type.slice! "Transaction"
      owner = Object.const_get(t_type).find(x.owner_id)
      owner.created_by_id = x.users_id
      owner.save
    end

  end

  task :set_other_general_to_pilots => :environment do
    pilots = User.where(:level => "Pilot")
    pilots.each do |p|
      p.privileges << Privilege.find(10)
      p.save
    end
  end


end

