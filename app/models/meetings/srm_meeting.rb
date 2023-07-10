class SrmMeeting < Meeting
  has_many :srm_agendas,foreign_key: "owner_id",class_name: "SrmAgenda",:dependent=>:destroy
  has_many :sras,foreign_key:"meeting_id",class_name:"Sra"
  accepts_nested_attributes_for :srm_agendas, allow_destroy: true
  #validates :imp, presence: true


  def get_id
    if self.custom_id.present?
      self.custom_id
    else
      self.id
    end
  end

  def self.get_meta_fields(*args)
    visible_fields = Meeting.get_meta_fields(*args)
  end

  def self.get_meta_fields_keys(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    keys = Meeting.get_meta_fields(nil).select { |val| (val[:visible].split(',') & visible_fields).any? }
                                          .map { |key| key[:field].to_s }

    keys
  end

  def self.get_headers
    [
      { :field => "get_id",                                         :title => "ID"},
      { :field => "status",                                         :title => "Status"},
      { :field => "get_host" ,                                      :title => "Host"},
      { :field => 'meeting_type',                                   :title => 'Meeting Type',     },
      { :field => 'title',                                          :title => 'Title', options: CONFIG.custom_options['Meeting Titles']},
      { :field => "get_time",         :param => "review_start",     :title => "Review Start"},
      { :field => "get_time",         :param => "review_end",       :title => "Review End"},
      { :field => "get_time",         :param => "meeting_start",    :title => "Meeting Start"},
      { :field => "get_time",         :param => "meeting_end",      :title => "Meeting End"},
      { :field => "get_sras_count",                                 :title => "Included SRAs"}
    ]
  end

  def get_sras_count
    sras.length
  end

  def has_user(user)
    if CONFIG::GENERAL[:global_admin_default] && user.global_admin?
      true
    elsif user.has_access('srm_meetings', 'admin', admin: CONFIG::GENERAL[:global_admin_default])
      true
    elsif self.host.present? && (self.host.users_id == user.id)
      true
    else
      self.invited?(user)
    end
  end

end
