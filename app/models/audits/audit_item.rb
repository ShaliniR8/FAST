class AuditItem < ChecklistItem
  belongs_to :audit,foreign_key:"owner_id",class_name: "Audit"
  belongs_to :user, foreign_key: "user_id", class_name: "User"
  after_create :find_created_by

  def self.get_headers
  	[

  		{:field=>"title",:title=>"Title"},
  		{:field=>"department",:title=>"Department"},
  		{:field=>"reference_number",:title=>"Reference Number"},
  		{:field=>"requirement",:title=>"Requirement"},
      {:field=>"level_of_compliance",:title=>"Level of Compliance"},
      {:field=>"status",:title=>"Status"}
  	]
  end

  def find_created_by
  end


  def get_created_by
    if user.present? 
      user.full_name
    else
      created_by
    end
  end

  def self.get_status
    [
      'New',
      'Open',
      'Completed'
    ]
  end

  def self.get_level_of_compliance
    [
      'Meets Requirements',
      'Unsat',
      'Other'
    ]
  end

end