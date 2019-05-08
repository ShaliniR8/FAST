class PolymorphicComments < ActiveRecord::Migration
  def self.up
    [
      'Audit',
      'Evaluation',
      'Finding',
      'Inspection',
      'Investigation',
      'Meeting',
      'Record',
    ].each do |type|
      execute "update viewer_comments set type = replace(type, '#{type}Comment', '#{type}')"
    end
    execute "update viewer_comments set type = replace(type, 'SubmissionNote', 'Submission')"
    rename_column :viewer_comments, :type, :owner_type
  end

  def self.down
    [
      'Audit',
      'Evaluation',
      'Finding',
      'Inspection',
      'Investigation',
      'Meeting',
      'Record',
    ].each do |type|
      execute "update viewer_comments set owner_type = replace(owner_type, '#{type}', '#{type}Comment')"
    end
    execute "update viewer_comments set owner_type = replace(owner_type, 'Submission', 'SubmissionNote')"
    rename_column :viewer_comments, :owner_type, :type
  end
end
