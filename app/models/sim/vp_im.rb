class VpIm < Im
  def self.display_name
    "SMS VP/Part 5 IM"
  end

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


