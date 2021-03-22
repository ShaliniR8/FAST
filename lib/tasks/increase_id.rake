INCREMENT = 50000
RUN_TEST = true

ASSOCIATION_NAME = 0
FIELD_NAME = 1

#
UPDATE_INFO = {
  Submission: {
  # CLASS_NAME:       [[:ASSOCIATION_NAME,  :COLUMN_NAME   ]]
    SubmissionField:  [[:submission_fields, :submissions_id]],
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]], # update owner_id at the end
    Transaction:      [[:transactions, :owner_id]],
    Message:          [[:messages, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  Record: {
    RecordField:      [[:record_fields, :records_id ]],
    Submission:       [[:submission, :records_id]],
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    CorrectiveAction: [[:corrective_actions, :records_id]],
    # Sra:              [[:sra, :owner_id]],
    # Investigation:    [[:investigation, :owner_id]],
    Child:            [[:children, :owner_id]],
    # Parent:           [[:parents, :owner_id]],
    Message:          [[:messages, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  Report: {
    Record:           [[:records, :reports_id]],
    CorrectiveAction: [[:corrective_actions, :reports_id]],
    AsapAgenda:       [[:agendas, :event_id]],
    Connection:       [[:child_connections, :id], [:child_connections, :child_id]],
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Sra:              [[:sra, :owner_id]],
    # Investigation:    [[:investigation, :owner_id]],
    # Child:            [[:children, :owner_id]],
    # Parent:           [[:parents, :owner_id]],
    Message:          [[:messages, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    Occurrence:       [[:occurrences, :owner_id]],
  },
  Meeting: {
    Connection:       [[:owner_connections, :owner_id]],
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Message:          [[:messages, :owner_id]],
    # Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  CorrectiveAction: {
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Verification:     [[:verifications, :owner_id]],
    # ExtensionRequest: [[:extension_requests, :owner_id]],
    # Message:          [[:messages, :owner_id]],
    # Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  Evaluation: {
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Message:          [[:messages, :owner_id]],
    # Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  Sra: {
    Hazard:           [[:hazards, :sra_id]],
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Child:            [[:children, :owner_id]],
    # Parent:           [[:parents, :owner_id]],
    Verification:     [[:verifications, :owner_id]],
    # ExtensionRequest: [[:extension_requests, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
    Message:          [[:messages, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  Hazard: {
    RiskControl:      [[:risk_controls, :hazard_id]],
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Child:            [[:children, :owner_id]],
    # Parent:           [[:parents, :owner_id]],
    Verification:     [[:verifications, :owner_id]],
    ExtensionRequest: [[:extension_requests, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    # Message:          [[:messages, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  },
  RiskControl: {
    ViewerComment:    [[:comments, :owner_id]],
    Attachment:       [[:attachments, :id], [:attachments, :owner_id]],
    Transaction:      [[:transactions, :owner_id]],
    # Child:            [[:children, :owner_id]],
    # Parent:           [[:parents, :owner_id]],
    Verification:     [[:verifications, :owner_id]],
    ExtensionRequest: [[:extension_requests, :owner_id]],
    # Message:          [[:messages, :owner_id]],
    Notice:           [[:notices, :owner_id]],
    # Occurrence:       [[:occurrences, :owner_id]],
  }
}

class IncrementValidation
  def self.get_ids(object_name, label)
    puts "#{object_name.upcase} #{label}"
    objects = Object.const_get(object_name).all
    {}.tap do |result|
      UPDATE_INFO[object_name].values.each do |fields_hash|
        fields_hash.each do |field_hash|
          assocication_name = field_hash[ASSOCIATION_NAME]
          column_name = field_hash[FIELD_NAME]
          key_name = "#{assocication_name}_#{column_name}".to_sym

          puts "    getting #{assocication_name} #{column_name}..."
          result[key_name] = objects.map { |x| x.send(assocication_name) }
                                    .select { |x| x.present? }
                                    .flatten.map {|x| x.send(column_name) }
        end
      end
      puts '    getting ids...'
      result[:id] = objects.map(&:id)
    end
  end


  def self.validate_ids(object_name, before, after)
    puts "#{object_name.upcase} RESULT"

    UPDATE_INFO[object_name].values.each do |fields_hash|
      fields_hash.each do |field_hash|
        assocication_name = field_hash[ASSOCIATION_NAME]
        column_name = field_hash[FIELD_NAME]
        key_name = "#{assocication_name}_#{column_name}".to_sym

        is_attribute_increased(key_name.upcase, before[key_name], after[key_name])
      end
    end

    is_attribute_increased('ID', before[:id], after[:id])
  end


  def self.are_same_arrays(first, second)
    (first-second).blank? and (second-first).blank?
  end


  def self.is_attribute_increased(label, before, after)
    before = before.map { |x| x + INCREMENT}
    puts " - #{label}: " + (are_same_arrays(before, after)  ? 'PASSED' : 'FAILED')
  end
end

desc 'Increase IDs for all objects'
task increase_id: :environment do
  UPDATE_INFO.each do |object_name, attributes|
    increase_ids(object_name, attributes)
  end
end


def increase_ids(object_name, attributes)
  before_ids = IncrementValidation.get_ids(object_name, 'BEFORE') if RUN_TEST
  update_ids(object_name, attributes)
  after_ids = IncrementValidation.get_ids(object_name, 'AFTER') if RUN_TEST

  IncrementValidation.validate_ids(object_name, before_ids, after_ids) if RUN_TEST
end


def update_ids(object_name, attributes)
  puts "#{object_name.upcase} PROCESSING"
  Object.const_get(object_name).all.each do |object|
    next if object.id > INCREMENT

    id_before = object.id
    id_after  = object.id + INCREMENT

    attributes.each do |associated_object_name, fields_hash|
      fields_hash.each do |field_hash|
        if field_hash[FIELD_NAME] == :owner_id
          update_object_owner(associated_object_name, object_name, id_before, id_after)
        elsif field_hash[FIELD_NAME] == :id
          update_associated_objects_id(object, associated_object_name, field_hash[ASSOCIATION_NAME])
        else
          update_object_attribute(associated_object_name, field_hash[FIELD_NAME], id_before, id_after)
        end
      end
    end

    update_id(object_name, id_before, id_after)
  end
end


def update_id(object_name, id_before, id_after)
  Object.const_get(object_name).where(id: id_before).update_all(id: id_after)
end


def update_associated_objects_id(object, associated_object_name, association_name)
  object.send(association_name).each do |item|
    associated_object = Object.const_get(associated_object_name).where(id: item.id)
    if associated_object.present?
      associated_object.update_all(id: item.id + INCREMENT)
      updated_item = Object.const_get(associated_object_name).find(item.id + INCREMENT)
      update_attachment_directory_name(updated_item) if associated_object_name == :Attachment
    end
  end
end


def update_object_attribute(object_name, field_name, id_before, id_after)
  Object.const_get(object_name).where("#{field_name} = #{id_before}").update_all("#{field_name} = #{id_after}")
end


def update_object_owner(object_name, owner_name, id_before, id_after)
  objects = Object.const_get(object_name).where(owner_type: owner_name, owner_id: id_before)
  objects.update_all(owner_id: id_after) if objects.present?
end


def update_attachment_directory_name(associated_object)
  new_id = associated_object.id
  new_path = "/public/uploads/attachment/name/#{new_id}"
  new_full_path = File.join([Rails.root] + [new_path])

  prev_id = associated_object.id - INCREMENT
  prev_path = "/public/uploads/attachment/name/#{prev_id}"
  prev_full_path = File.join([Rails.root] + [prev_path])

  if File.exist? prev_full_path
    File.rename(prev_full_path, new_full_path)
  else
    puts "  [warn] File #{prev_path} does not exist!"
  end
end
