# All Safety Assurance-specific models inherit from this object:
  # This provides module-specific methods for Safety Assurance
  # Any new methods added here are available to all Safety Assurance Objects
module Sa
  class SafetyAssuranceBase < ProsafetBase

    self.abstract_class = true

    def panel_btns
      {
        attachments: !(['Completed', 'Pending Approval'].include? self.status)
      }
    end

    def get_approver_name
      self.approver.full_name unless self.approver.nil?
    end

    def get_responsible_user_name
      self.responsible_user.full_name
    end

  end
end
