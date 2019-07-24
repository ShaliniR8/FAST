class PolymorphicContacts < ActiveRecord::Migration

  def self.up
    [ 'Audit',
      'Finding',
      'Investigation',
      'Inspection',
      'Evaluation',
    ].each do |type|
      execute "update contacts set type = replace(type, '#{type}Contact', '#{type}')"
    end
    rename_column :contacts, :type, :owner_type
  end

  def self.down
    [ 'Audit',
      'Investigation',
      'Inspection',
      'Finding',
      'Evaluation',
    ].each do |type|
      execute "update contacts set owner_type = replace(owner_type, '#{type}', '#{type}Contact')"
    end
    rename_column :contacts, :owner_type, :type
  end

end
