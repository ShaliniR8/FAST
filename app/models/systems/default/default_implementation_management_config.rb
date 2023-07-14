class DefaultImplementationManagementConfig
  include ConfigTools
  # DO NOT COPY THIS CONFIG AS A TEMPLATE FOR NEW AIRLINES
    # Please look at other airline config definitions and mimic them
    # All configs inherit from their Default counterparts, then overload the default values when needed

  GENERAL = {
    # General Module Features:

    # Airline-Specific Features:
    has_framework:              false,      # BSK feature for content management off-label use - default off
  }

  HIERARCHY = {
    display_name: 'SMS IM',
    display_workflow_diagram_module: false,
    objects: {

    },
    menu_items: {
      'Frameworks' => {
        title: 'Frameworks', path: '#',
        display: proc{|user:,**op| CONFIG.im::GENERAL[:has_framework]},
        subMenu: [
          {title: 'IMs', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'ims_path(:type=>"FrameworkIm")',
            display: proc{|user:,**op| true }},
          {title: 'New', path: 'new_im_path(:type=>"FrameworkIm")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Im'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Packages', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'packages_path(:type=>"FrameworkImPackage")',
            display: proc{|user:,**op| true }},
          {title: 'Meetings', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'sms_meetings_path(:type=>"FrameworkMeeting")',
            display: proc{|user:,**op| true }},
          {title: 'New', path: 'new_sms_meeting_path(:type=>"FrameworkMeeting")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Meeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'VP/Part 5' => {
        title: 'VP/Part 5', path: '#',
        display: proc{|user:,**op| true},
        subMenu: [
          {title: 'VP/Part 5', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'ims_path(:type=>"VpIm")',
            display: proc{|user:,**op| true }},
          {title: 'New', path: 'new_im_path(:type=>"VpIm")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Im'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Packages', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'packages_path(:type=>"VpImPackage")',
            display: proc{|user:,**op| true }},
          {title: 'Meetings', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'sms_meetings_path(:type=>"VpMeeting")',
            display: proc{|user:,**op| true }},
          {title: 'New', path: 'new_sms_meeting_path(:type=>"VpMeeting")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Meeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      'Job Aid' => {
        title: 'Job Aid', path: '#',
        display: proc{|user:,**op| true},
        subMenu: [
          {title: 'Job Aids', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'ims_path(:type=>"JobAid")',
            display: proc{|user:,**op| true }},
          {title: 'New', path: 'new_im_path(:type=>"JobAid")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Im'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'Packages', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'packages_path(:type=>"JobAidPackage")',
            display: proc{|user:,**op| true }},
          {title: 'Meetings', path: '#', header: true,
            display: proc{|user:,**op| true }},
          {title: 'All', path: 'sms_meetings_path(:type=>"JobMeeting")',
            display: proc{|user:,**op| true }},
          {title: 'New', path: 'new_sms_meeting_path(:type=>"JobMeeting")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Meeting'), user, 'new', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
    }
  }

end
