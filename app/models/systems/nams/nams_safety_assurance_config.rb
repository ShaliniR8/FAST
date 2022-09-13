class NAMSSafetyAssuranceConfig < DefaultSafetyAssuranceConfig

  GENERAL = DefaultSafetyAssuranceConfig::GENERAL.merge({
    # General Module Features:
    checklist_version:                  '3',
    enable_recurrence:                  true,

    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    objects:{
      'Finding' => {
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification recommendation sms_action approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              if owner.owner.class.name == "ChecklistRow"
                true
              else
                DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op)
              end
            },
          },
        }),
      },
      'SmsAction' => {
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_parent attach_in_message expand_all],
            #TODO: Complete Notices<=Notifications Update and add set_alert after view_parent
          #INLINE
          *%i[assign complete request_extension schedule_verification cost approve_reject reopen comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              if owner.owner.class.name == "ChecklistRow"
                true
              else
                DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op)
              end
            },
          },
        }),
      },
      'Recommendation' => {
        actions: [
          #TOP
          *%i[delete override_status edit launch deid_pdf pdf view_parent attach_in_message expand_all],
          #INLINE
          *%i[assign complete request_extension schedule_verification approve_reject reopen comment]
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          assign: {
            access: proc { |owner:,user:,**op|
              if owner.owner.class.name == "ChecklistRow"
                true
              else
                DICTIONARY::ACTION[:assign][:access].call(owner:owner,user:user,**op)
              end
            },
          },
        }),
      },
    }
  })

end
