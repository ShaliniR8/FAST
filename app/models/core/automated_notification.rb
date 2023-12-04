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

  def self.tasks_for_automated_notifications
    {
      "Tasks(Event)" => "reports_sms_tasks",
      "Tasks(Audit)" => "audits_sms_tasks",
      "Tasks(Inspection)" => "inspections_sms_tasks",
      "Tasks(Evaluation)" => "evaluations_sms_tasks",
      "Tasks(Investigation)" => "investigations_sms_tasks",
    }
  end

  def self.get_object_types
    objects = AccessControl.object_types
    if CONFIG::GENERAL[:task_notifications]
      objects = tasks_for_automated_notifications.merge(objects).sort.to_h
    end
    objects
  end

  def get_object_type
    object_type.include?("sms_task") ? "sms_tasks" : object_type
  end

  def get_anchor_date_fields
    case get_object_type.classify
    when 'Meeting'
      get_auto_fields(get_object_type, 'form', 'datetimez')
    when 'Verification'
      get_auto_fields(get_object_type, 'auto', 'date')
    else
      get_auto_fields(get_object_type, 'form', 'date')
    end
  end

  def get_audience_fields
    get_auto_fields(get_object_type, 'auto', 'user')
  end


  private

    def get_auto_fields(object_type, visibility, field_type)
      Object.const_get(object_type.classify).get_meta_fields(visibility)
      .select{|header| header[:type] == field_type}
      .map{|x| [x[:title], x[:field]]}.to_h
    end

end
