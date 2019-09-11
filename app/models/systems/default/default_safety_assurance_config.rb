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
      'Audit' => 'Audit',
      'Inspection' => 'Inspection',
      'Evaluation' => 'Evaluation',
      'Investigation' => 'Investigation',
      'Finding' => 'Finding',
      'SmsAction' => 'Corrective Action',
    }
  }

end
