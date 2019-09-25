class CreatesMeetingRelatedPrivileges < ActiveRecord::Migration
  def self.up

    if BaseConfig.airline[:code] == 'SCX'
      module_access = AccessControl.where(entry: 'ASAP').first

      Template.all.each do |template|
        full_access_rule = AccessControl.where(action: 'full', entry: template.name).first rescue nil
        viewer_access_rule = AccessControl.where(action: 'viewer', entry: template.name).first rescue nil

        if full_access_rule.present?
          privilege = Privilege.create(
            name: "#{template.name} Full",
            description: "Users will be able to view any #{template.name} reports.",
            example: "Meeting participants who should see any #{template.name} reports in the meeting.")
          puts "#{module_access.id}, #{full_access_rule.id}"
          Assignment.create(access_controls_id: module_access.id, privileges_id: privilege.id)
          Assignment.create(access_controls_id: full_access_rule.id, privileges_id: privilege.id)
          privilege.save
        end

        if viewer_access_rule.present?
          privilege = Privilege.create(
            name: "#{template.name} Viewer",
            description: "Users will be able to view any Viewer Access Enabled #{template.name} reports.",
            example: "Meeting participants who should see any #{template.name} reports in the meeting.")
          Assignment.create(access_controls_id: module_access.id, privileges_id: privilege.id)
          Assignment.create(access_controls_id: viewer_access_rule.id, privileges_id: privilege.id)
          privilege.save
        end
      end
    end

  end

  def self.down
    if BaseConfig.airline[:code] == 'SCX'
      Privilege.where('name LIKE "BLAIR TEST:%"').destroy_all
    end
  end
end
