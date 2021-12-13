if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end
end

desc 'Send email '
task :create_survey_checklists => [:environment] do |t|

  logger = Logger.new("log/survey_creation.log")

  logger.info '#######################################'
  logger.info '#####     SURVEY CREATION LOG     #####'
  logger.info '#######################################'
  logger.info "SERVER DATE+TIME: #{DateTime.now.strftime("%F %R")}\n"

  logger.info "#{ENV['SURVEY_ID']}"
  logger.info "#{ENV['USERS']}"
  logger.info '#######################################'

  users                = ENV['USERS'][1..-2].split(', ')
  survey_id            = ENV['SURVEY_ID'].to_i
  checklist_template   = Checklist.preload(checklist_rows: :checklist_cells).find(SafetySurvey.find(survey_id).checklist.id)

  users.each do |uid|
    new_checklist = checklist_template.clone

    checklist_template.checklist_rows.each do |row|
      new_row = row.clone
      new_checklist.checklist_rows << new_row
      row.checklist_cells.each{ |cell| new_row.checklist_cells << cell.clone }
    end
    new_checklist.save

    comp = Completion.where({owner_id: survey_id, owner_type: 'SafetySurvey', user_id: uid}).first rescue nil
    if comp.present?
      comp.complete_date = nil
      comp.checklist = new_checklist
      comp.save
    else
      new_comp = Completion.new({owner_id: survey_id, owner_type: 'SafetySurvey', user_id: uid})
      new_comp.checklist = new_checklist
      new_comp.save
    end
  end
end
