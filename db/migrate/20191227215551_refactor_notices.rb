class RefactorNotices < ActiveRecord::Migration
  def self.up
    change_column :notices, :status, :integer, :default => 1
    add_column :notices, :category, :integer, :default => 1
    add_column :notices, :end_date, :date


    type_hash_map = {
      'sras' => 'SRA',
      'risk_controls' => 'RiskControl',
      'audits' => 'Audit',
      'evaluations' => 'Evaluation',
      'inspections' => 'Inspection',
      'investigations' => 'Investigation',
      'findings' => 'Finding',
      'sms_actions' => 'SmsAction',
      'recommendations' => 'Recommendation',
      'submissions' => 'Submisssion',
      'records' => 'Record',
      'reports' => 'Report',
      'corrective_actions' => 'CorrectiveAction',
      'meetings' => 'Meeting',
      'messages' => 'Message'
    }

    # migrate old notices to fit into new notice table
    Notice.all.each do |notice|
      content = notice.content
      href_match = /href\s*=\s*(?:'|")([^'"]*)(?:'|")/.match(content)
      if href_match.present?
        parsed_content = href_match[1].split('/').reverse
        notice.status = 1
        notice.category = 1
        notice.owner_id, notice.owner_type = parsed_content[0], type_hash_map[parsed_content[1]]
        notice.content = content.gsub(/<a.*/, '').strip
        notice.save
      end
    end

    remove_column :notices, :expire_date
    remove_column :notices, :action
    remove_column :notices, :create_email
  end

  def self.down
    # add_column :notices, :expire_date, :date
    # add_column :notices, :action, :string
    # add_column :notices, :create_email, :boolean
    # change_column :notices, :status, :string
    # remove_column :notices, :end_date
    # remove_column :notices, :category
  end
end
