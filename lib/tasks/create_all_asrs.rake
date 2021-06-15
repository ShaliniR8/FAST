task :create_all_asrs => :environment do
  Record.all.each_with_index do |record, index|
    if record.can_send_to_asrs?
      record.export_nasa_asrs
      p "#{index+1}: Record ##{record.id} xml file is created"
    end
  end
end