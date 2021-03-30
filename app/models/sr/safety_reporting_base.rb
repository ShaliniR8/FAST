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
      event_date.strftime(CONFIG.getTimeFormat[:datetimeformat]) rescue ''
    end


    def get_user_id
      anonymous ? 'Anonymous' : user_id
    end


    def submit_name
      return 'Anonymous' if self.anonymous?
      return (self.created_by.full_name rescue 'Disabled')
    end


    def submitted_date
      created_at.strftime("%Y-%m-%d") rescue ''
    end


    def get_submitter_name
      val = nil
      if anonymous
        val = 'Anonymous'
      else
        val = created_by.full_name
        if CONFIG::GENERAL[:sabre_integration].present?
          if created_by.employee_number.present?
            val = val + " (#{created_by.employee_number})"
          end
        end
      end
      val
    end

    def get_submitter_id
      created_by.id
    end

    def get_template
      template.name rescue ''
    end


    def time_diff(base)
      return 100000.0 if event_date.blank?
      diff = ((event_date - base.event_date) / (24*60*60)).abs
    end


    def getTimeZone()
      ActiveSupport::TimeZone.all.map(&:name)
    end

  end
end
