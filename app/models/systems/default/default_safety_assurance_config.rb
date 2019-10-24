class DefaultSafetyAssuranceConfig
  include ConfigTools
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
        actions: [
          #TOP
          *%i[delete override_status edit sign deid_pdf pdf viewer_access attach_in_message expand_all private_link],
          #INLINE
          *%i[assign complete approve_reject reopen contact task cost finding comment],
        ].map{ |act| DICTIONARY::ACTION[act] },
        panels: %i[tasks contacts findings costs signatures comments attachments transaction_log],
      },
      'Inspection' => {
        title: 'Inspection',
        actions: [
          #TOP
          %i[delete override_status edit sign deid_pdf pdf viewer_access attach_in_message expand_all],
          #INLINE
          %i[assign complete approve_reject reopen task cost contact finding comment],
        ].map{ |act| DICTIONARY::ACTION[act] },
        panels: %i[tasks contacts requirements findings costs signatures comments attachments transaction_log],
      },
      'Evaluation' => {
        title: 'Evaluation',
        actions: [
          #TOP
          %i[delete override_status edit sign deid_pdf pdf viewer_access attach_in_message expand_all],
          #INLINE
          %i[assign complete approve_reject reopen task cost contact finding comment],
        ].map{ |act| DICTIONARY::ACTION[act] },
        panels: %i[tasks contacts requirements findings costs signatures comments attachments transaction_log],
      },
      'Investigation' => {
        title: 'Investigation',
        actions: [
          #TOP
          %i[delete override_status edit sign deid_pdf pdf view_parent viewer_access attach_in_message expand_all],
          #INLINE
          %i[assign complete approve_reject reopen recommendation contact task cost sms_action finding comment],
        ].map{ |act| DICTIONARY::ACTION[act] },
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
