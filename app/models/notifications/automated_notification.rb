class AutomatedNotification < ActiveRecord::Base

  belongs_to :creator,  foreign_key: 'created_by', class_name: 'User'

  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    [
      {field: 'object_type',        title: 'Object Type',     num_cols: 6,  type: 'select_map',   visible: 'index,form,show', required: true, options: get_object_types},
      {field: 'anchor_date_field',  title: 'Anchor Date',     num_cols: 6,  type: 'select_map',   visible: 'index,form,show', required: true, options: :get_anchor_date_fields},
      {field: 'anchor_status',      title: 'Anchor Status',   num_cols: 6,  type: 'select',       visible: 'index,form,show', required: true},
      {field: 'audience_field',     title: 'Audience',        num_cols: 6,  type: 'select_map',   visible: 'index,form,show', required: true, options: :get_audience_fields},
      {field: 'interval',           title: 'Interval (Days)', num_cols: 6,  type: 'text',         visible: 'index,form,show', required: true},
      {field: 'subject',            title: 'Subject',         num_cols: 12, type: 'text',         visible: 'index,form,show', required: true},
      {field: 'content',            title: 'Content',         num_cols: 12, type: 'textarea',     visible: 'index,form,show', required: true},
      {field: 'created_by',         title: 'Created By',      num_cols: 6,  type: 'user',         visible: 'index,show',      required: true},

    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end


  def self.get_object_types
    AccessControl.object_types
  end

  def get_anchor_date_fields
    Object.const_get(object_type.classify).get_meta_fields('form')
      .select{|header| header[:type] == 'date'}
      .map{|x| [x[:title], x[:field]]}.to_h
  end

  def get_audience_fields
    Object.const_get(object_type.classify).get_meta_fields('form')
      .select{|header| header[:type] == 'user'}
      .map{|x| [x[:title], x[:field]]}.to_h
  end

end
