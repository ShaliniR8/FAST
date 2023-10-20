class RUHSafetyReportingConfig < DefaultSafetyReportingConfig

  GENERAL = DefaultSafetyReportingConfig::GENERAL.merge({
    # General Module Features:
    show_submitter_name:              true,
    enable_dual_report:               true,
    submission_local_time_zone:       true,
    submission_description_required:  true,
    configurable_agenda_dispositions: true,
    # Airline-Specific Features:
  })

  HIERARCHY = DefaultSafetyReportingConfig::HIERARCHY.deep_merge({
    objects: {
      'Submission' => {
        actions: [
          #TOP
          *%i[delete pdf deid_pdf view_parent view_report attach_in_message message_submitter expand_all],
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
                (owner.user_id == user.id || user.has_access('submissions','admin',admin:CONFIG::GENERAL[:global_admin_default],strict:true))
            },
          },
        }),
      },
      'CorrectiveAction' => {
          fields: {
            response: {
              visible: '',
          },
        }
      },
    },
    menu_items: {
      'FAA Reports' => {
        title: 'FAA Reports', path: '#',
        display: proc{|user:,**op| false},
        subMenu: [
          {title: 'All', path: 'faa_reports_path',
            display: proc{|user:,**op| false}},
          {title: 'New', path: 'new_faa_report_path',
            display: proc{|user:,**op| false }},
        ]
      },

    }
  })
end
