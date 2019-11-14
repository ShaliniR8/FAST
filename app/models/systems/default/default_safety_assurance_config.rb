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
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[tasks contacts findings costs signatures comments attachments transaction_log],
      },

      'Inspection' => {
        title: 'Inspection',
        actions: [
          #TOP
          *%i[delete override_status edit sign deid_pdf pdf viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete approve_reject reopen task cost contact finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[tasks contacts requirements findings costs signatures comments attachments transaction_log],
      },

      'Evaluation' => {
        title: 'Evaluation',
        actions: [
          #TOP
          *%i[delete override_status edit sign deid_pdf pdf viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete approve_reject reopen task cost contact finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[tasks contacts requirements findings costs signatures comments attachments transaction_log],
      },

      'Investigation' => {
        title: 'Investigation',
        actions: [
          #TOP
          *%i[delete override_status edit sign deid_pdf pdf view_parent viewer_access attach_in_message expand_all],
          #INLINE
          *%i[assign complete approve_reject reopen recommendation contact task cost sms_action finding comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc },
        panels: %i[findings sms_actions recommendations contacts tasks costs signatures comments attachments transaction_log],
      },

      'Finding' => {
        title: 'Finding',
        actions: [
          #TOP
          *%i[delete override_status edit deid_pdf pdf view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete recommendation sms_action approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
             DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op) &&
             (owner.immediate_action || owner.owner.status == 'Completed')
            },
          },
        }),
        panels: %i[attachments transaction_log],
      },

      'SmsAction' => {
        title: 'Corrective Action',
        actions: [
          #TOP
          *%i[delete override_status edit deid_pdf pdf view_parent attach_in_message expand_all],
            #TODO: Complete Notices<=Notifications Update and add set_alert after view_parent
          #INLINE
          *%i[assign complete request_extension schedule_validation cost approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op) &&
              (owner.immediate_action || (%w[Completed].include? owner.owner.status rescue true))
            },
          },
        }),
        panels: %i[comments attachments transaction_log]
      },

      'Recommendation' => {
        title: 'Recommendation',
        actions: [
          #TOP
          *%i[delete override_status edit deid_pdf pdf view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete approve_reject reopen comment]
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op) &&
              (owner.immediate_action || (%w[Completed].include? owner.owner.status rescue true))
            },
          },
        }),
        panels: %i[comment attachments transaction_log]
      }
    },
  }


end
