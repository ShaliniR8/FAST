class SBASafetyPromotionConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them or copy the template configs
    # All configs inherit from their Default counterparts, then overload the default values when needed


  GENERAL = {
    # General Module Features:
  }


  HIERARCHY = {
    display_name: 'Safety Promotion',
    display_workflow_diagram_module: false,
    objects: {
      'Newsletter' => {
      },

      'SafetySurvey' => {
      },

      'SafetyBadge' => {
      },
    },

    menu_items: {
      'Newsletters' => {
        title: 'Newsletters', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('Newsletter'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('Newsletter'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'newsletters_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Newsletter'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_newsletter_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Newsletter'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },

      'Safety Surveys' => {
        title: 'Safety Surveys', path: '#',
        display: proc{|user:,**op| priv_check.call(Object.const_get('SafetySurvey'), user, 'index', CONFIG::GENERAL[:global_admin_default], true) ||
                                   priv_check.call(Object.const_get('SafetySurvey'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)},
        subMenu: [
          {title: 'All', path: 'safety_surveys_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SafetySurvey'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'New', path: 'new_safety_survey_path',
            display: proc{|user:,**op| priv_check.call(Object.const_get('SafetySurvey'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      }
    }
  }

end
