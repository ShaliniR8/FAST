class RecurrencesController < ApplicationController

  before_filter :login_required
  before_filter :recurrence_enabled

  def recurrence_enabled
    unless CONFIG.sa::GENERAL[:enable_recurrence]
      redirect_to errors_path
    end
  end

  def child_access_validation(con_name, act_name)
    redirect_to errors_path unless current_user.has_access(con_name.downcase.pluralize, act_name, admin: true)
  end
  helper_method :child_access_validation

  def create
    params.each do |key, data|
      case key
      when 'audit'
        @table = Audit
      when 'investigation'
        @table = Investigation
      when 'evaluation'
        @table = Evaluation
      when 'inspection'
        @table = Inspection
      end
    end
    @template = params[:audit] || params[:investigation] || params[:evaluation] || params[:inspection]
    template = @table.create(@template)
    template.template = true
    template.save!
    @recurrence = Recurrence.create(params[:recurrence])
    @recurrence.template_id = template.id
    @recurrence.created_by_id = current_user.id
    @recurrence.form_type = @table.name
    @recurrence.save!
    child_access_validation(@table.name,'admin')
    redirect_to recurrence_path(@recurrence), flash: {success: "Recurrent #{@table} created."}
  end

  def edit
    load_options
    @recurrence = Recurrence.find(params[:id])
    @fields = Recurrence.get_meta_fields('form')
    @type = @recurrence.form_type
    @table = Object.const_get(@type)
    @template = @table.find(@recurrence.template_id)
    @template_fields = @table.get_meta_fields('form')
    child_access_validation(@type,'admin')
  end

  def index
    if params.key? :form_type
      child_access_validation(params[:form_type].downcase.pluralize,'admin')
      @table = Recurrence.where(form_type: Object.const_get(params[:form_type]))
    else
      redirect_to errors_path unless current_user.global_admin?
      @table = Recurrence
    end
    @headers = @table.get_meta_fields('index')
    @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
    handle_search
  end


  def load_options
    #load_options Equivalent; in Audits, Investigations, Evaluations, and Inspections.
    @privileges = Privilege.find(:all)
    @privileges.keep_if{|p| keep_privileges(p, 'evaluations')}.sort_by!{|a| a.name}
    @plan = {"Yes" => true, "No" => false}
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    @cause_headers = FindingCause.get_headers
    risk_matrix_initializer
  end
  helper_method :load_options


  def new
    load_options
    @recurrence = Recurrence.new
    @fields = Recurrence.get_meta_fields('form')
    @type = params[:form_type]
    @table = Object.const_get(@type)
    @template = @table.new
    @template_fields = @table.get_meta_fields('form')
    child_access_validation(@type,'admin')
  end


  def show
    @recurrence = Recurrence.find(params[:id])
    @fields = Recurrence.get_meta_fields('show')
    @type = Object.const_get(@recurrence.form_type)
    @template = @type.find(@recurrence.template_id)
    @template_fields = @type.get_meta_fields('show')
    @children = @recurrence.children
    child_access_validation(@type.name,'admin')
  end

  def update
    @recurrence = Recurrence.find(params[:id])
    @recurrence.update_attributes(params[:recurrence])
    @type = Object.const_get(@recurrence.form_type)
    @template = @type.find(@recurrence.template_id)
    template = params[:audit] || params[:investigation] || params[:evaluation] || params[:inspection]
    @template.update_attributes(template)
    child_access_validation(@type.name,'admin')
    redirect_to recurrence_path(@recurrence)
  end

  def destroy
    recurrence = Recurrence.find(params[:id])
    @type = Object.const_get(recurrence.form_type)
    child_access_validation(@type.name,'admin')
    template = @type.find(recurrence.template_id)
    template.destroy
    recurrence.destroy
    redirect_to "/recurrences?form_type=#{@type}", flash: {danger: "Recurrence ##{params[:id]} deleted."}
  end

end
