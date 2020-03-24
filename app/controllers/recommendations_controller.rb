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

  before_filter :login_required
  before_filter(only: [:show]) { check_group('recommendation') }
  before_filter :define_owner, only:[
    :destroy,
    :edit,
    :interpret,
    :new_attachment,
    :override_status,
    :show,
    :update
  ]

  def define_owner
    @class = Object.const_get('Recommendation')
    @owner = @class.find(params[:id])
  end

  def index
    object_name = controller_name.classify
    @object = CONFIG.hierarchy[session[:mode]][:objects][object_name]
    @table = Object.const_get(object_name).preload(@object[:preload])
    @default_tab = params[:status]

    records = @table.filter_array_by_emp_groups(@table.can_be_accessed(current_user), params[:emp_groups])
    if params[:advance_search].present?
      handle_search
    else
      @records = records
    end
    filter_records(object_name, controller_name)
    records = @records.to_a & records.to_a if @records.present?

    @records_hash = records.group_by(&:status)
    @records_hash['All'] = records
    @records_id = @records_hash.map { |status, record| [status, record.map(&:id)] }.to_h
  end


  def new
    @privileges = Privilege.find(:all)
    @parent = Object.const_get(params[:owner_type])
      .find(params[:owner_id])
      .becomes(Object.const_get(params[:owner_type])) rescue nil
    @owner = @parent.recommendations.new
    @fields = Recommendation.get_meta_fields('form')
  end


  def create
    @parent = Object.const_get(params[:owner_type]).find(params[:owner_id])
    @owner = @parent.recommendations.create(params[:recommendation])
    redirect_to @owner, flash: {success: "Recommendation created."}
  end


  def show
    @type = @owner.owner_type
    @fields = Recommendation.get_meta_fields('show')
  end


  def edit
    @privileges = Privilege.find(:all)
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable}
    @type = get_recommendation_owner(@owner)
    @users.keep_if{|u| u.has_access(@type, 'edit')}
    @headers = User.get_headers
    @fields = Recommendation.get_meta_fields('form')
  end


  def update
    transaction = true
    @owner.update_attributes(params[:recommendation])
    send_notification(@owner, params[:commit])
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
      else
        @owner.complete_date = Time.now
        @owner.close_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
    when 'Approve'
      @owner.complete_date = Time.now
      @owner.close_date = Time.now
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:recommendation][:status]}"
      params[:recommendation][:close_date] = params[:recommendation][:status] == 'Completed' ? Time.now : nil
    when 'Add Attachment'
      transaction = false
    end
    # @owner.update_attributes(params[:recommendation])
    @owner.status = update_status || @owner.status
    if transaction
      Transaction.build_for(
        @owner,
        params[:commit],
        current_user.id,
        transaction_content
      )
    end
    @owner.save
    redirect_to recommendation_path(@owner)
  end


  def print
    @deidentified = params[:deidentified]
    @recommendation = Recommendation.find(params[:id])
    html = render_to_string(:template => "/recommendations/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Recommendation_##{@recommendation.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end
end
