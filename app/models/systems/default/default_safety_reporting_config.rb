class DefaultSafetyReportingConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them or copy the template configs
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:
    enable_orm:               false,     # Enables ORM Reports - default off
    show_submitter_name:      true,      # Displays submitter names when access to show (admins will always see it)- default on
    submission_description:   true,      # Changes Character Limit or adds General Description - default on
    template_nested_fields:   false,     # WIP nested smart forms functionality - default off

    # Airline-Specific Features:
    observation_phases_trend: false,     # Specific Feature for BSK - default off
    event_summary:            false,     # Adds summary Tab for Events in Safety Reporting nav bar - default off
    event_tabulation:         false,     # Adds Tabulation Tab for Events in Safety Reporting nav bar - default off
  }

  OBSERVATION_PHASES = [
    'Observation Phase',
    'Condition',
    'Threat', 'Sub Threat',
    'Error', 'Sub Error',
    'Human Factor', 'Comment'
  ]

  HIERARCHY = {
    display_name: 'ASAP',
    objects: {

      'Submission' => {
        title: 'Submission',
        actions: [
          #TOP
          *%i[delete pdf deid_pdf view_report attach_in_message message_submitter expand_all],
          #INLINE
          *%i[comment],
        ].reduce({}) { |acc,act| acc[act] = DICTIONARY::ACTION[act]; acc }.deep_merge({
          delete: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:delete][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          pdf: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:pdf][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          deid_pdf: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:deid_pdf][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          view_report: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:view_report][:access].call(owner:owner,user:user,**op) &&
                op[:template_access]
            }
          },
          comment: {
            access: proc { |owner:,user:,**op|
              DICTIONARY::ACTION[:comment][:access].call(owner:owner,user:user,**op) &&
                (owner.user_id == user.id || user.has_access('submissions','admin',admin:true,strict:true))
            },
          },
        }),
        panels: %i[]
      },


      'Record' => {
        title: 'Report',
      },

      'Report' => {
        title: 'Event',
      },
      'CorrectiveAction' => {
        title: 'Corrective Action',
      },
    }
  }



end
