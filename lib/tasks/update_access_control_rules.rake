namespace :rules do
  require 'securerandom'
  @logger = Logger.new("log/update_access_control_rules.log")

    task :update_template_rule_mappings => [:environment] do |t, args|
      @logger.info '#####################################'
      @logger.info '###### UPDATING TEMPLATE RULES ######'
      @logger.info '#####################################'
      @logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

      AccessControl.where(entry: Template.all.map(&:name), action: 'viewer').each do |r|
        save = r.update_attributes({action: 'viewer_template_deid'})
        if save
          @logger.info "Updated viewer rule for Template #{r.entry}"
        else
          @logger.info "Failed to update viewer rule for Template #{r.entry}"
        end
      end

      AccessControl.where(entry: Template.all.map(&:name), action: 'full').each do |r|
        save = r.update_attributes({action: 'viewer_template_id'})
        if save
          @logger.info "Updated full rule for Template #{r.entry}"
        else
          @logger.info "Failed to update full rule for Template #{r.entry}"
        end
      end
      AccessControl.where(entry: 'submissions', action: 'new').map(&:destroy)

      @logger.info "SERVER DATE+TIME OF CONCLUSION: #{DateTime.now.strftime("%F %R")}\n\n"
    end
end
