if Rails::VERSION::MAJOR == 3 && Rails::VERSION::MINOR == 0 && RUBY_VERSION >= "2.0.0"
  module ActiveRecord
    module Associations
      class AssociationProxy
        def send(method, *args)
          if proxy_respond_to?(method, true)
            super
          else
            load_target
            @target.send(method, *args)
          end
        end
      end
    end
  end
end

class RecommendationsController < SafetyAssuranceController

  before_filter :set_table_name, :login_required
  before_filter(only: [:show]) { check_group('recommendation') }
  before_filter :define_owner, only:[
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update,
  ]

  before_filter(only: [:new])    {set_parent_type_id(:recommendation)}
  before_filter(only: [:create]) {set_parent(:recommendation)}
  after_filter(only: [:create])  {create_parent_and_child(parent: @parent, child: @recommendation)}

  def define_owner
    @class = Object.const_get('Recommendation')
    @owner = @class.find(params[:id])
  end


  def set_table_name
    @table_name = "recommendations"
  end


  # def index
  #   object_name = controller_name.classify
  #   @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
  #   params[:type].present? ? @table = Object.const_get(object_name).preload(@object[:preload]).where(owner_type: params[:type])
  #                          : @table = Object.const_get(object_name).preload(@object[:preload])
  #   @default_tab = params[:status]

  #   records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
  #   if params[:advance_search].present?
  #     handle_search
  #   else
  #     @records = records
  #   end
  #   filter_records(object_name, controller_name)
  #   records = @records.to_a & records.to_a if @records.present?

  #   @records_hash = records.group_by(&:status)
  #   @records_hash['All'] = records
  #   @records_hash['Overdue'] = records.select{|x| x.overdue}
  #   @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  # end


  def new
    @privileges = Privilege.find(:all)

    if params[:owner_type].present?
      @parent_old = Object.const_get(params[:owner_type])
        .find(params[:owner_id])
        .becomes(Object.const_get(params[:owner_type])) rescue nil
      @owner = @parent_old.recommendations.new
    else # from Launch Object
      @owner = Finding.new
    end

    @fields = Recommendation.get_meta_fields('form')
  end


  def create
    if params[:owner_type].present?
      @parent_old = Object.const_get(params[:owner_type]).find(params[:owner_id])
      @recommendation = @parent_old.recommendations.create(params[:recommendation])
    else # from Launch Object
      @recommendation = @parent.recommendations.create(params[:recommendation])
    end
    notify_on_object_creation(@recommendation)
    redirect_to @recommendation, flash: {success: "Recommendation created."}
  end


  def show
    @has_status = true
    @type = @owner.owner_type
    @fields = Recommendation.get_meta_fields('show')
  end


  def edit
    @has_status = true
    @privileges = Privilege.find(:all)
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable}
    @type = get_recommendation_owner(@owner)
    @users.keep_if{|u| u.has_access(@type, 'edit')}
    @headers = User.get_headers
    @fields = Recommendation.get_meta_fields('form')
  end


end
