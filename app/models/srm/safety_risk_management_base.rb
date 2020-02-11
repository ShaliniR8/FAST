# All Safety Risk Management-specific models inherit from this object:
  # This provides module-specific methods for Safety Risk Management
  # Any new methods added here are available to all Safety Risk Management Objects
module Srm
  class SafetyRiskManagementBase < ProsafetBase

    self.abstract_class = true

    def panel_btns
      {
        attachments: !(['Completed', 'Pending Approval'].include? self.status)
      }
    end

  end
end
