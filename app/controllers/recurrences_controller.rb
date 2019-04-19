class RecurrencesController < ApplicationController


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
  end

  def index
    if params.key? :form_type
      @table = Recurrence.where(form_type: Object.const_get(params[:form_type]))
    elsif current_user.admin?
      @table = Recurrence
    else
      @table = Recurrence.none
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
  end


  def show
    @recurrence = Recurrence.find(params[:id])
    @fields = Recurrence.get_meta_fields('show')
    @type = Object.const_get(@recurrence.form_type)
    @template = @type.find(@recurrence.template_id)
    @template_fields = @type.get_meta_fields('show')
    @children = @recurrence.children
  end

  def update
    @recurrence = Recurrence.find(params[:id])
    @recurrence.update_attributes(params[:recurrence])
    @type = Object.const_get(@recurrence.form_type)
    @template = @type.find(@recurrence.template_id)
    template = params[:audit] || params[:investigation] || params[:evaluation] || params[:inspection]
    @template.update_attributes(template)
    redirect_to recurrence_path(@recurrence)
  end

end
