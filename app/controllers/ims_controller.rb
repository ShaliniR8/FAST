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



class ImsController < ApplicationController

  before_filter :login_required

  require 'csv'

  def index
    @ims = true
    @table = Im
    if params[:status].present?
      if params[:status] == "Overdue"
        @records = @table.within_timerange(params[:start_date], params[:end_date]).select{|x| x.overdue}
      else
        @records = @table.within_timerange(params[:start_date], params[:end_date]).where("status=?",params[:status])
      end
    else
      @records = @table.within_timerange(params[:start_date], params[:end_date])
    end
    handle_search
    @headers = @table.get_headers
    @title = Object.const_get(params[:type]).display_name
    @table_name = "ims"
  end



  def advanced_search
    @im = true
    @path = ims_path
    meta_field_args = ['show']
    meta_field_args.push('admin') if current_user.admin?
    @terms = Im.get_meta_fields(*meta_field_args).keep_if{|x| x[:field].present?}
    render :partial => "shared/advanced_search"
  end



  def schedule
    im = Im.find(params[:id])
    im.status = 'Open'
    Transaction.build_for(
      im,
      'Open',
      current_user.id
    )
    im.date_open = Time.now.to_date
    im.save
    if im.evaluator.present?
      notify(im,
        notice: {users_id: im.evaluator.id, content: "IM Plan ##{im.get_id} is Assigned to you."},
        mailer: true,
        subject: 'IM Plan Assigned')
    end
    redirect_to im_path(im)
  end


  def new
    @im = Object.const_get(params[:type]).new
    load_options

  end

  def create
    im = Object.const_get(params[:type]).new(params[:im])
    if im.save
      redirect_to im_path(im), flash: {success: "#{params[:type].titleize} created."}
    end
  end

  def destroy
    im = Im.find(params[:id])

    redirect_to ims_path(:type => im.type), flash: {info: "#{im.type.titleize} ##{im.id} has been deleted."}
    im.destroy
    #redirect_to root_url
  end

  def show
    @im = Im.find(params[:id])
    @checklist_headers = Object.const_get(@im.type + 'Item').get_headers
  end

  def edit
    @im = Im.find(params[:id])
    load_options
  end




  def update
    im = Im.find(params[:id])
    old_status = im.status
    new_status = params[:im][:status]
    type = im.type
    alert = "#{type.titleize} updated."
    if im.update_attributes(params[:im])
      if new_status.present?
        if old_status == "Pending Review" && new_status == "Completed"
          Transaction.build_for(
            im,
            'Completed',
            current_user.id,
            'Approved'
          )
          im.date_complete=Time.now.to_date
          im.save
          notify(im,
            notice: {
              users_id: im.evaluator.id,
              content: "IM Plan ##{im.get_id} has been approved by the preliminary reviewer"},
            mailer: true,
            subject: 'IM Plan Approved')
        elsif old_status == "Pending Review" && new_status == "Open"
          Transaction.build_for(
            im,
            'Rejected',
            current_user.id
          )
          notify(im,
            notice: {
              users_id: im.evaluator.id,
              content: "IM Plan ##{im.get_id} has been rejected by the preliminary reviewer"},
            mailer: true,
            subject: 'IM Plan Rejected')
        end
      end
      redirect_to im_path(im), flash: {success: alert}
    end
  end

  def reoccur
    @base = Im.find(params[:id])
    load_options
    @im = @base.clone
    @base.attachments.each do |x|
      temp = Attachment.new(:name=>x.name, :caption=>x.caption)
      @im.attachments.push(temp)
    end
    @im.save
    redirect_to im_path(@im)
  end

  def new_task
    @im = Im.find(params[:id])
    load_options
    @task = @im.tasks.new
    render :partial => 'task'
  end

  def new_contact
    @im = Im.find(params[:id])
    @contact = @im.contacts.new
    render :partial => 'contact'
  end

  def new_expectation
    @im = Im.find(params[:id])
    load_options
    @expectation = FrameworkExpectation.new
    render :partial => 'expectation'
  end

  def load_options
    @users = User.find(:all)
    @users.keep_if{|u| !u.disable && u.has_access('ims', 'edit')}
    @headers = User.get_headers
    @apply = CONFIG.custom_options['Departments']
    @org = Im.get_org
    @aid = Im.get_aid
  end

  def transit
    im = Im .find(params[:id])
    im.status = "Transit to VP/Part 5"
    if im.save
      redirect_to im_path(im)
    end
  end

  def new_checklist
    im = Im.find(params[:id])
    @path = upload_checklist_im_path(im)
    render :partial => "audits/checklist"
  end

  def upload_checklist
    im=Im.find(params[:id])
    if !params[:append].present?
      im.clear_checklist
    end
    if params[:checklist].present?
      upload=File.open(params[:checklist].tempfile)
      begin
        Checklist.transaction do
          CSV.foreach(upload,{
            :headers=>:true,
            :header_converters => lambda { |h| h.downcase.gsub(' ', '_') }
            }) do |row|
            #Rails.logger.info (row.inspect)
            Object.const_get(im.type+'Item').create(row.to_hash.merge({:owner_id=>im.id}))
          end
          Transaction.build_for(
            im,
            'Upload Checklist',
            current_user.id
          )
        end
      rescue Exception => e
        Rails.logger.info e
      end
    end
    redirect_to im_path(im)
  end

  def download_checklist
      @im = Im.find(params[:id])
  end

  def update_checklist
      @im = Im.find(params[:id])
      @checklist_headers=Object.const_get(@im.type+'Item').get_headers
      render :partial=>"update_checklist"
  end


  def new_attachment
    @owner=Im.find(params[:id]).becomes(Im)
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end

  def new_package
    @im=Im.find(params[:id])
    @item=ChecklistItem.find(params[:item_id])
    @package=Object.const_get(@im.type+"Package").new
    @fields=Package.get_fields
      render :partial=>"new_package"
  end

  def show_package
    @item=ChecklistItem.find(params[:item_id])
    @headers=Package.get_headers
    render :partial=>"show_package"
  end

  def complete
    im = Im.find(params[:id])
    if im.reviewer.present?
      im.date_complete=Time.now.to_date
      Transaction.build_for(
        im,
        'Pending Review',
        current_user.id
      )
      notify(im,
        notice: {
          users_id: im.evaluator.id,
          content: "IM Plan ##{im.get_id} needs your review"},
        mailer: true,
        subject: 'IM Plan Pending Review')
      im.status="Pending Review"
      im.save
    else
      Transaction.build_for(
        im,
        'Complete',
        current_user.id
      )
      im.status="Completed"
      im.save
    end
    redirect_to im_path(im)
  end
  def approve
    @im = Im.find(params[:id])
    @status=params[:commit] == "approve" ? "Completed" : "Open"
    render :partial =>"comment"
  end

  def print
    @im = Im.find(params[:id])
    html = render_to_string(:template=>"/ims/print.html.erb")
    pdf=PDFKit.new(html)
    pdf.stylesheets <<("#{Rails.root}/public/css/bootstrap.css")
    title = ""
    if @im.type == "FrameworkIm"
      title = "Framework_IM"
    elsif @im.type == "VpIm"
      title = "VP/Part5_IM"
    else
      title = "Job_Aid"
    end
    send_data pdf.to_pdf, :filename => "#{title}_##{@im.get_id}.pdf"
  end

  def enable
    @im=Im.find(params[:id])
    @im.viewer_access=!@im.viewer_access
    Transaction.build_for(
      @im,
      "#{(@im.viewer_access ? 'Enable' : 'Disable')} Viewer Access",
      current_user.id
    )
    @im.save
    redirect_to im_path(@im)
  end

end
