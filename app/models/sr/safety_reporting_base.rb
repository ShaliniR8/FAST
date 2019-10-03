# All Safety Reporting-specific models inherit from this object:
  # This provides module-specific methods for Safety Reporting
  # Any new methods added here are available to all Safety Reporting Objects
module Sr
  class SafetyReportingBase < ProsafetBase
  self.abstract_class = true


  def categories
    template.categories
  end


  def get_date
    event_date.strftime("%Y-%m-%d") rescue ''
  end


  def get_id
    custom_id || id
  end

  def get_description
    return '' if self.description.blank?
    return self.description[0..50] + '...' if self.description.length > 50
    return self.description
  end


  def get_event_date
    event_date.strftime("%Y-%m-%d %H:%M:%S") rescue ''
  end


  def get_user_id
    anonymous ? 'Anonymous' : user_id
  end


  def get_submitter_name
    anonymous ? 'Anonymous' : created_by.full_name
  end

  def get_template
    template.name
  end


  end
end
