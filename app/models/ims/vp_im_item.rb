class VpImItem < ChecklistItem
  belongs_to :im,foreign_key:"owner_id",class_name: "VpIm"
  has_many :packages,foreign_key:"owner_id",class_name:"VpImPackage",:dependent => :destroy
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

  def self.get_status
    [
      'New',
      'Open',
      'Completed'
    ]
  end

  def self.get_level_of_compliance
    [
      'None',
      'Planned',
      'Implemented'
    ]
  end

end