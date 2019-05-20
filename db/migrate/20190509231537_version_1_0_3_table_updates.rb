class Version103TableUpdates < ActiveRecord::Migration
  def self.up
    execute "UPDATE notices SET created_at = DATE_SUB(expire_date, INTERVAL 3 DAY) where created_at IS NULL;"

    [
      'corrective_actions',
      'audits',
      'inspections',
      'evaluations',
      'investigations',
      'findings',
      'sms_actions',
      'recommendations',
      'sras',
      'risk_controls',
    ].each do |type|
      execute "UPDATE #{type} SET status = 'New' WHERE status = 'Pending Release';"
      execute "UPDATE #{type} SET status = 'Assigned' WHERE status = 'Open';"
      execute "UPDATE #{type} SET status = 'Completed' WHERE status = 'Closed';"
    end

  end

  def self.down
  end
end
