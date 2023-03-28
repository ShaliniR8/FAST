class SafetySurvey < Sp::SafetyPromotionBase
  extend AnalyticsFilters

  include Attachmentable
  include Commentable
  include Transactionable
  include Completable
  include Noticeable

  belongs_to :created_by, foreign_key: 'user_id', class_name: 'User'
  has_one :checklist, as: :owner, dependent: :destroy
  accepts_nested_attributes_for :checklist


  def self.get_meta_fields(*args)
    visible_fields = (args.empty? ? ['index', 'form', 'show'] : args)
    return [
      { field: "id",                title: "ID",                         num_cols: 12, type: "text", visible: 'index,show',       required: false},
      { field: "title",             title: "Title",                      num_cols: 12, type: "text", visible: 'index,form,show',  required: true},
      { field: "user_id",           title: "Creator",                    num_cols: 12, type: "user", visible: 'index,show',       required: true},
      { field: "status",            title: "Status",                     num_cols: 10, type: "text", visible: 'index,show',       required: false},
      { field: "complete_by_date",  title: "Complete By Date",           num_cols: 10, type: "date", visible: 'index,form,show',  required: true},
      { field: "publish_date",      title: "Publish Date",               num_cols: 10, type: "date", visible: 'index,show',       required: false},
      { field: "archive_date",      title: "Archive Date",               num_cols: 10, type: "date", visible: 'index,show',       required: false},
    ].select{|f| (f[:visible].split(',') & visible_fields).any?}
  end

  def self.get_headers
    [
      # { field: "id",                title: "ID"},
      { field: "title",             title: "Title"},
      { field: "user_id",           title: "Creator"},
      { field: "status",            title: "Status"},
      { field: "complete_by_date",  title: "Complete By Date"},
      { field: "publish_date",      title: "Publish Date"},
      { field: "archive_date",      title: "Archive Date"},
    ]
  end

  def self.progress
    {
      "New"       => { :score => 0,    :color => "default"},
      "Published" => { :score => 50,   :color => "warning"},
      "Archived"  => { :score => 100,  :color => "warning"},
    }
  end

  def my_action(uid)
    user = User.find(uid) rescue nil
    if user.present?
      if status == "Published"
        if user_id == uid
          "Creator"
        else
          completion_arr = completions.all.map {|c| c.user_id == uid ? c.complete_date : nil}.keep_if{|x| x.present?}
          if completion_arr.present?
            if completion_arr.last > complete_by_date
              "Completed Late"
            else
              "Completed"
            end
          else
            "Not Completed"
          end
        end
      else
        if status == "Archived"
          "Archived"
        else
          "Unpublished"
        end
      end
    else
      ''
    end
  end

  def get_total_users
    DistributionList.preload(:distribution_list_connections).where(id: distribution_list.split(',')).map{|d| d.get_user_ids}.flatten.uniq.count rescue 0
  end

end
