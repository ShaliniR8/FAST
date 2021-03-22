namespace :eccairs do


  require 'csv'
  require 'rake/packagetask'

  task :export => [:environment] do |t, args|

    desc "Exports of E5X for ECCAIRS Integration"

    @records = (JSON.load(ENV['RECORDS']) || [1])
    email = (ENV['EMAIL'] || 'noc@prosafet.com')

    Record.where(id: @records).each do |record|
      record.eccairs_export
    end

    sh "cd integrations/eccairs && zip Occurrences_#{Date.today.strftime('%Y%m%d')}.zip *.xml && rm *.xml"
    sh "cd integrations/eccairs && mv Occurrences_#{Date.today.strftime('%Y%m%d')}.zip Occurrences_#{Date.today.strftime('%Y%m%d')}.e5x"

    file = File.read("integrations/eccairs/Occurrences_#{Date.today.strftime('%Y%m%d')}.e5x")
    NotifyMailer.send_export(email, "ECCAIRS_export.e5x", file)

    sh "cd integrations/eccairs && rm *.e5x"

  end


  task :load_attributes => [:environment] do |t, args|
    csv_text = File.read('lib/tasks/ECCAIRS/eccairs_attributes.csv')
    csv = CSV.parse(csv_text, headers: true)
    eccairs_attributes = []
    csv.each do |row|
      eccairs_attributes << [
        row["Attribute Synonym"],
        row["Attribute ID"],
        row["Parent Entity Synonym"],
        row["Parent Entity ID"],
        row["ECCAIRS Datatype"],
        row["UM default"],
        row["Valuelist ID"],
        row["Attribute Sequence"],
      ]
    end
    columns = [
      :attribute_synonym,
      :attribute_id,
      :entity_synonym,
      :entity_id,
      :datatype_id,
      :default_unit_id,
      :value_list_id,
      :attribute_sequence,
    ]
    eccairs_attributes.each do |attributes|
      EccairsAttribute.create(
        columns[0] => attributes[0],
        columns[1] => attributes[1],
        columns[2] => attributes[2],
        columns[3] => attributes[3],
        columns[4] => attributes[4],
        columns[5] => attributes[5],
        columns[6] => attributes[6],
        columns[7] => attributes[7],
      )
    end
  end


  task :load_eccairs_units => [:environment] do |t, args|
    csv_text = File.read('lib/tasks/ECCAIRS/eccairs_units.csv')
    csv = CSV.parse(csv_text, headers: true)
    eccairs_attributes = []
    csv.each do |row|
      eccairs_attributes << [
        row["UM Synonym"],
        row["UM ID"]
      ]
    end
    columns = [
      :unit_synonym,
      :unit_id]
    eccairs_attributes.each do |attributes|
      EccairsUnit.create(
        columns[0] => attributes[0],
        columns[1] => attributes[1],
      )
    end
  end


end
