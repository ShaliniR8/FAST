desc "Migrate CauseOption to OccurrenceTemplates (Root Cause)"
task :migrate_root_cause => :environment do

  # reset Occurrence Template table
  ActiveRecord::Base.connection.execute("TRUNCATE  occurrence_templates")

  record = CauseOption.where(level: 0) # Default
  p '-- Create ' + record[0].name + ' section!'
  root = OccurrenceTemplate.create(title: record[0].name, format: 'section', label: 'Root Cause')

  index = 1

  # level 1
  record[0].children.each do |child|
    if !child.hidden?
      index += 1
      p '  --[' + child.level.to_s + '] ' + child.name + ' section (' + index.to_s + ', ' + root.id.to_s + ')'
      level_1 = OccurrenceTemplate.create(title: child.name, format: 'section', parent_id: root.id)

      # level 2
      child.children.each do |child2|
        if !child2.hidden?
          index += 1
          p '    --[' + child2.level.to_s + '] ' + child2.name + ' checkbox (' + index.to_s + ', ' +level_1.id.to_s + ')'
          level_2 = OccurrenceTemplate.create(title: child2.name, format: 'checkbox', parent_id: level_1.id, options: ' ')

          options = ''
          # level 3
          child2.children.each do |child3|
            if !child3.hidden?
              index += 1
              p '      --[' + child3.level.to_s + '] ' + child3.name + ' option (' + index.to_s + ', ' +level_2.id.to_s + ')'

              if level_2.options != ' '
                options = options + "\r\n" + child3.name
                # p options
              else
                options = child3.name
              end

              level_2.update_attributes(options: options)
            end
          end
        end
      end
    end
  end
end


