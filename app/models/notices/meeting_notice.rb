class MeetingNotice < Notice
  belongs_to :meeting, foreign_key: "owner_id",class_name:"Meeting"
end
