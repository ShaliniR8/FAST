class SrmMeeting < Meeting
  has_many :srm_agendas,foreign_key: "owner_id",class_name: "SrmAgenda",:dependent=>:destroy
  has_many :sras,foreign_key:"meeting_id",class_name:"Sra"
  accepts_nested_attributes_for :srm_agendas
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

  def self.get_headers
    [
      { :field => "get_id",                                         :title => "ID"},
      { :field => "get_time",         :param => "review_start",     :title => "Review Start"},
      { :field => "get_time",         :param => "review_end",       :title => "Review End"},
      { :field => "get_time",         :param => "meeting_start",    :title => "Meeting Start"},
      { :field => "get_time",         :param => "meeting_end",      :title => "Meeting End"},
      { :field => "get_sras_count",                                 :title => "Included SRAs"},
      { :field => "get_host" ,                                      :title => "Host"},
      { :field => "status",                                         :title => "Status"}
    ]
  end

  def get_sras_count
    sras.length
  end


end
