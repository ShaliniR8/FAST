class SBASafetyAssuranceConfig < DefaultSafetyAssuranceConfig
  
  HIERARCHY = DefaultSafetyAssuranceConfig::HIERARCHY.deep_merge({
    menu_items: {
      "Findings" => {
        subMenu: [
          {title: 'All', path: 'findings_path(status: "New")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Audits', path: 'findings_path(status: "New", :type=>"Audit")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
          {title: 'For Inspectionssdfs', path: 'findings_path(status: "New", :type=>"Inspection")',
            display: proc{|user:,**op| false}},
          {title: 'For Evaluations', path: 'findings_path(status: "New", :type=>"Evaluation")',
            display: proc{|user:,**op| false}},
          {title: 'For Investigations', path: 'findings_path(status: "New", :type=>"Investigation")',
            display: proc{|user:,**op| priv_check.call(Object.const_get('Finding'), user, 'index', CONFIG::GENERAL[:global_admin_default], true)}},
        ]
      },
      "Inspections" => {
        display: proc{|user:,**op| false}
      },
      "Evaluations" => {
        display: proc{|user:,**op| false}
      }
    }
  }).tap do |hierarchy|
    hierarchy[:objects].except!("Inspection", "Evaluation")
  end
end
