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

  before_filter(only: [:show]) { check_group('recommendation') }
  before_filter :define_owner, only:[
    :approve,
    :assign,
    :comment,
    :complete,
    :edit,
    :destroy,
    :new_attachment,
    :override_status,
    :reopen,
    :show,
    :update
  ]

  def define_owner
    @class = Object.const_get('Recommendation')
    @owner = @class.find(params[:id])
  end

  def index
    @table = Object.const_get('Recommendation')
    @headers = Recommendation.get_meta_fields('index')
    @terms = Recommendation.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search

    if !current_user.admin? && !current_user.has_access('recommendations','admin')
      cars = Recommendation.where('status in (?) and responsible_user_id = ?',
        ['Assigned', 'Pending Approval', 'Completed'], current_user.id)
      cars += Recommendation.where('approver_id = ?', current_user.id)
      cars += Recommendation.where('created_by_id = ?', current_user.id)
      @records = @records & cars
    end
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

    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Recommendation ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Recommendation Assigned')
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "Recommendation ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Recommendation Pending Approval')
      else
        @owner.complete_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Recommendation ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Recommendation Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Recommendation ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Recommendation Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:recommendation][:status]}"
    end
    @owner.update_attributes(params[:recommendation])
    @owner.status = update_status || @owner.status
    Transaction.build_for(
      @owner,
      params[:commit],
      current_user.id,
      transaction_content
    )
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
