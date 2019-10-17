class DefaultSafetyAssuranceConfig
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:
    checklist_version:            '3',   # Determines which version of the checklist is being used - default 3
    enable_recurrence:            true,  # Enables recurrent audits, evaluations, and inspections - default on
  }

  HIERARCHY = {
    display_name: 'Safety Assurance',
    objects: {
      'Audit' => {
        title: 'Audit',
        panels: %i[tasks contacts findings costs signatures comments attachments transaction_log],
      },
      'Inspection' => {
        title: 'Inspection',
        panels: %i[tasks contacts requirements findings costs signatures comments attachments transaction_log],
      },
      'Evaluation' => {
        title: 'Evaluation',
        panels: %i[tasks contacts requirements findings costs signatures comments attachments transaction_log],
      },
      'Investigation' => {
        title: 'Investigation',
        panels: %i[findings sms_actions recommendations contacts tasks costs signatures comments attachments transaction_log],
      },
      'Finding' => {
        title: 'Finding',
      },
      'SmsAction' => {
        title: 'Corrective Action',
      },
    },
  }

end
