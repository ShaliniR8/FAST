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



class AuditsController < ApplicationController
  require 'csv'


  # before_filter :login_required
  before_filter :oauth_load
  before_filter :auditor_check, :only => [:edit,:new]
  before_filter(only: [:show]) { check_group('audit') }


  def auditor_check
    Rails.logger.info "Check if current user is an auditor of this audit."
  end



  def reoccur
    @base = Audit.find(params[:id])
    load_options
    @audit = @base.clone
    @base.attachments.each do |x|
      temp = AuditAttachment.new(
        :name => x.name,
        :caption => x.caption)
      @audit.attachments.push(temp)
    end
    @audit.save
    AuditTransaction.create(
      :users_id => current_user.id,
      :action => "Reoccur",
      :owner_id => @base.id,
      :content => "Make Reoccurring Audit: ##{@audit.get_id}",
      :stamp => Time.now)
    AuditTransaction.create(
      :users_id => current_user.id,
      :action => "Create",
      :owner_id => @audit.id,
      :content => "Reoccur Audit: ##{@base.get_id}",
      :stamp => Time.now)
    redirect_to edit_audit_path(@audit), flash: {success: "This is a reoccurance of #{@base.id}. Update fields as needed"}
  end



  def index
    respond_to do |format|
      format.html do
        @table = Object.const_get("Audit")
        @headers = @table.get_meta_fields('index')
        @terms = @table.get_meta_fields('show').keep_if{|x| x[:field].present?}
        handle_search
        filter_audits
      end
      format.json { index_as_json }
    end
  end

  def new
    @audit = Audit.new
    load_options
    @fields = Audit.get_meta_fields('form')
  end



  def create
    audit = Audit.create(params[:audit])
    redirect_to audit_path(audit), flash: {success: "Audit created."}
  end


  def edit
    @audit = Audit.find(params[:id])
    load_options
    @fields = Audit.get_meta_fields('form')
  end



  def new_task
    @audit = Audit.find(params[:id])
    load_options
    @task = AuditTask.new
    render :partial => 'task'
  end



  def viewer_access
    audit = Audit.find(params[:id])
    audit.viewer_access = !audit.viewer_access
    if audit.viewer_access
      content = "Viewer Access Enabled"
    else
      content = "Viewer Access Disabled"
    end
    AuditTransaction.create(
      :users_id => current_user.id,
      :action => "Viewer Access",
      :owner_id => audit.id,
      :content => content,
      :stamp => Time.now)
    audit.save
    redirect_to audit_path(audit)
  end



  def new_contact
    @audit = Audit.find(params[:id])
    @contact = AuditContact.new
    render :partial => 'contact'
  end



  def new_requirement
    @audit = Audit.find(params[:id])
    @requirement = AuditRequirement.new
    @fields = AuditRequirement.get_meta_fields('form')
    load_options
    render :partial => 'requirement'
  end



  def upload_checklist
    audit = Audit.find(params[:id])
    if !params[:append].present?
      audit.clear_checklist
    end
    if params[:checklist].present?
      upload = File.open(params[:checklist].tempfile)
      begin
        CSV.foreach(upload,{
          :headers => :true,
          :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }
          }) do |row|
          AuditItem.create(row.to_hash.merge({:owner_id => audit.id}))
        end
      rescue Exception => e
        redirect_to audit_path(audit)
        return
      end
    end
    AuditTransaction.create(
      :users_id => current_user.id,
      :action => "Upload Checklist",
      :owner_id => params[:id],
      :stamp => Time.now)
    redirect_to audit_path(audit)
  end


  def add_checklist
    @audit = Audit.find(params[:id])
    render :partial => "/checklist_templates/select_checklist"
  end

  def populate_checklist
    @checklist_template = ChecklistTemplate.find(params[:checklist_template])
    @checklist_template.build_checklist_records(@audit)
    redirect_to audit_path(@audit)
  end


  def new_checklist
    @audit = Audit.find(params[:id])
    @path = upload_checklist_audit_path(@audit)
    render :partial => 'checklist'
  end



  def update
    @owner = Audit.find(params[:id]).becomes(Audit)
    case params[:commit]
    when 'Assign'
      @owner.open_date = Time.now
      notify(@owner.responsible_user,
        "Audit ##{@owner.id} has been assigned to you." + g_link(@owner),
        true, 'Audit Assigned')
    when 'Complete'
      if @owner.approver
        update_status = 'Pending Approval'
        notify(@owner.approver,
          "Audit ##{@owner.id} needs your Approval." + g_link(@owner),
          true, 'Audit Pending Approval')
      else
        @owner.complete_date = Time.now
        update_status = 'Completed'
      end
    when 'Reject'
      notify(@owner.responsible_user,
        "Audit ##{@owner.id} was Rejected by the Final Approver." + g_link(@owner),
        true, 'Audit Rejected')
    when 'Approve'
      @owner.complete_date = Time.now
      notify(@owner.responsible_user,
        "Audit ##{@owner.id} was Approved by the Final Approver." + g_link(@owner),
        true, 'Audit Approved')
    when 'Override Status'
      transaction_content = "Status overriden from #{@owner.status} to #{params[:audit][:status]}"
    end
    @owner.update_attributes(params[:audit])
    @owner.status = update_status || @owner.status
    AuditTransaction.create(
      users_id:   current_user.id,
      action:     params[:commit],
      owner_id:   @owner.id,
      content:    transaction_content,
      stamp:      Time.now
    )
    @owner.save
    respond_to do |format|
      format.html { redirect_to audit_path(@owner) }
      format.json { render :json => { :success => 'Audit Updated.' }, :status => 200 }
    end
  end


  def override_status
    @owner = Audit.find(params[:id]).becomes(Audit)
    render :partial => '/forms/workflow_forms/override_status'
  end

  def assign
    @owner = Audit.find(params[:id]).becomes(Audit)
    render :partial => '/forms/workflow_forms/assign', locals: {field_name: 'responsible_user_id'}
  end

  def complete
    @owner = Audit.find(params[:id]).becomes(Audit)
    render :partial => '/forms/workflow_forms/process'
  end

  def approve
    @owner = Audit.find(params[:id]).becomes(Audit)
    status = params[:commit] == "approve" ? "Completed" : "Assigned"
    render :partial => '/forms/workflow_forms/process', locals: {status: status}
  end

  def destroy
    Audit.find(params[:id]).destroy
    redirect_to audits_path, flash: {danger: "Audit ##{params[:id]} deleted."}
  end






  def show
    respond_to do |format|
      format.html do
        load_options
        @audit = Audit.find(params[:id])
        @fields = Audit.get_meta_fields('show')
        @recommendation_fields = FindingRecommendation.get_meta_fields('show')
        @type = 'audits'
        @checklist_headers = AuditItem.get_headers
      end
      format.json { show_as_json }
    end
  end



  def new_finding
    @audit = Audit.find(params[:id])
    @finding = AuditFinding.new
    @classifications = Finding.get_classifications
    load_options
    form_special_matrix(@finding, "audit[findings_attributes][0]", "severity_extra", "probability_extra")
    @fields = Finding.get_meta_fields('form')
    render :partial => "finding"
  end


  def load_options
    @privileges = Privilege.find(:all)
      .keep_if{|p| keep_privileges(p, 'audits')}
      .sort_by!{|a| a.name}
    @frequency = (0..4).to_a.reverse
    @like = Finding.get_likelihood
    @cause_headers = FindingCause.get_headers
    # @audit_types = Audit.get_audit_types
    risk_matrix_initializer
  end
  helper_method :load_options



  def update_checklist
    @audit = Audit.find(params[:id])
    @checklist_headers = AuditItem.get_headers
    render :partial => "update_checklist"
  end


  def update_checklist_records
    @owner = Audit.find(params[:id])
    render :partial => "checklist_templates/update_checklist_records"
  end



  def comment
    @owner = Audit.find(params[:id])
    @comment = AuditComment.new
    render :partial => "viewer_comment"
  end




  def print
    @deidentified = params[:deidentified]
    @audit = Audit.find(params[:id])
    html = render_to_string(:template=>"/audits/print.html.erb")
    pdf = PDFKit.new(html)
    pdf.stylesheets << ("#{Rails.root}/public/css/bootstrap.css")
    pdf.stylesheets << ("#{Rails.root}/public/css/print.css")
    filename = "Audit_#{@audit.get_id}" + (@deidentified ? '(de-identified)' : '')
    send_data pdf.to_pdf, :filename => "#{filename}.pdf"
  end



  def download_checklist
    @audit = Audit.find(params[:id])
  end



  def new_attachment
    @owner = Audit.find(params[:id])
    @attachment = AuditAttachment.new
    render :partial => "shared/attachment_modal"
  end

  def reopen
    @audit = Audit.find(params[:id])
    reopen_report(@audit)
  end

private

  def filter_audits
    @records = @records.where('template = ? OR template is ?', 0, nil)
    if !current_user.admin? && !current_user.has_access('audits', 'admin')
      audits = Audit.where('(status in (:status) AND responsible_user_id = :id) OR approver_id = :id', {
        status: ['Assigned', 'Pending Approval', 'Completed'], id: current_user[:id]
      })
      if current_user.has_access('audits', 'viewer')
        Audit.where({ viewer_access: true }).each do |viewable|
          if viewable.privileges.empty?
            audits += [viewable]
          else
            viewable.privileges.each do |privilege|
              current_user.privileges.include? privilege
              audits += [viewable]
            end
          end
        end
      end
      @records = @records.merge(audits)
    end
  end

#---------# For ProSafeT App 2019 #---------#
#-------------------------------------------#

  # Override index
  def index_as_json
    @records = Audit
    filter_audits

    json = {}

    # Convert to id map for fast audit lookup
    json[:audits] = @records
      .as_json(only: [:id, :status, :title, :completion])
      .map {|audit| audit['audit']}
      .reduce({}) { |audits, audit| audits.merge({ audit['id'] => audit }) }

    # Get ids of the 8 most recent audits
    recent_audits = @records
      .last(8)
      .as_json(only: :id)
      .map {|audit| audit['audit']['id'] }

    json[:recent_audits] = load_audits(*recent_audits)

    render :json => json
  end

  # Override show
  def show_as_json
    audit = load_audits(params[:id])
    render :json => audit
  end

  def load_audits(*ids)
    audits = Audit.where(id: ids).includes({
      checklists: { # Preload checklists to prevent N+1 queries
        checklist_header: :checklist_header_items,
        checklist_rows: :checklist_cells
      }
    })

    # Get all fields that will be shown
    @fields = Audit.get_meta_fields('show')
      .select{ |field| field[:field].present? }

    # Array of fields to whitelist for the JSON
    json_fields = @fields.map{ |field| field[:field].to_sym }

    # Include other fields that should always be whitelisted
    whitelisted_fields = [:id, *json_fields]

    json = audits
      .as_json(
        only: whitelisted_fields,
        include: { # Include checklist data required for mobile
          checklists: {
            only: [:id, :title],
            include: {
              checklist_header: {
                only: :id,
                include: {
                  checklist_header_items: {
                    only: [:id, :title, :data_type, :options, :editable, :display_order]
                  }
                }
              },
              checklist_rows: {
                only: [:id, :is_header],
                include: {
                  checklist_cells: {
                    only: [:id, :value, :checklist_header_item_id],
                  }
                }
              }
            }
          }
        }
      )
      .map { |audit| format_audit_json(audit) }

    if (ids.length == 1)
      json = json[0]
    else
      json = json.reduce({}) { |audits, audit| audits.merge({ audit['id'] => audit }) }
    end

    json
  end

  def format_audit_json(audit)
    json = audit['audit'].delete_if{ |key, value| value.blank? }
    # Default checklists to an empty array
    json[:checklists] = [] if json[:checklists].blank?

    checklist_headers = {}
    json[:checklists] = json[:checklists].reduce({}) do |checklists, checklist|
      # Gathers all checklist headers that belong to this audit's checklists
      id = checklist[:checklist_header]['id']
      if checklist_headers[id].blank?
        checklist_headers[id] = checklist[:checklist_header]
      end
      checklist.delete(:checklist_header)

      # Creates id maps for checklist rows and checklist cells
      checklist[:checklist_rows] = checklist[:checklist_rows].reduce({}) do |checklist_rows, row|
        row[:checklist_cells] = row[:checklist_cells].reduce({}) do |checklist_cells, cell|
          checklist_cells.merge({ cell['id'] => cell })
        end
        checklist_rows.merge({ row['id'] => row })
      end

       # Creates an id map for all checklists used in this audit
      checklists.merge({ checklist['id'] => checklist })
    end

    # Creates an id map for all checklist header items used in this audit
    json[:checklist_header_items] = checklist_headers.values
      .map{ |checklist_header| checklist_header[:checklist_header_items] }
      .flatten
      .reduce({}) do |checklist_header_items, item|
        checklist_header_items.merge({ item['id'] => item })
      end

    # Takes the id of each user field and replaces it with the
    # full name of the user corresponding to that id
    user_fields = @fields.select{ |field| field[:type] == 'user' }
    user_fields.map do |field|
      key = field[:field]
      user_id = json[key]
      if user_id
        json[key] = User.find(user_id).full_name rescue nil
      end
    end

    # Creates a key map for all the meta field titles that will be shown
    json[:meta_field_titles] = {}
    @fields.each do |field|
      key = field[:field]
      if json[key].present?
        json[:meta_field_titles][key] = field[:title]
      end
    end

    json
  end

end
