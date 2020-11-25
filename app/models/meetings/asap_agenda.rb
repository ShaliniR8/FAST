class AsapAgenda < Agenda
  belongs_to :meeting,foreign_key: 'owner_id', class_name:'Meeting'
  belongs_to :event,foreign_key:'event_id',class_name: 'Report'


  def self.get_headers
    [
      { title: 'Title',       field: :title},
      { title: 'Status',      field: :status},
      { title: 'User',        field: :get_user},
      { title: 'Created At',  field: :get_created},
      { title: 'Updated At',  field: :get_updated},
      { title: 'Discuss',     field: :discuss},
      { title: 'Dispositions',field: :disposition}
    ]
  end

  def disposition
    accepted == 1 ? 'Yes' : (accepted == 0 ? 'No' : accepted)
  end

  def discuss
    self.discussion ? 'Yes' : 'No'
  end

  def get_created
    self.created_at.present? ?  self.created_at.strftime('%Y-%m-%d %H:%M') : ''
  end

  def get_updated
    self.updated_at.present? ?  self.updated_at.strftime('%Y-%m-%d %H:%M') : ''
  end

  def get_user
    self.user.present? ? self.user.full_name : ''
  end

  def self.get_status
    ['New','Completed']
  end

end
