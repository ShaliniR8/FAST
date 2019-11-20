class PackagesController < ApplicationController

  before_filter :login_required

  def new
  end


  def advanced_search
    @im = true
    @path = packages_path
    meta_field_args = ['show']
    meta_field_args.push('admin') if current_user.admin?
    @terms = Package.get_meta_fields(*meta_field_args).keep_if{|x| x[:field].present?}
    render :partial => "shared/advanced_search"
  end


  def create
    package=Object.const_get(params[:type]).new(params[:package])
    if package.save
      redirect_to im_path(package.item.im)
    end
  end

  def update
    package=Package.find(params[:id]).becomes(Package)
    old_minutes = package.minutes
    if package.update_attributes(params[:package])
      package=Package.find(params[:id]).becomes(Package)
      redirect_to package.minutes == old_minutes ? package_path(package) : sms_meeting_path(package.meeting), flash: {success: "Package updated."}
    end
  end

  def edit
    @package=Package.find(params[:id])
    @fields=Package.get_fields
  end

  def show
    @headers=SmsAgenda.get_headers
    @package=Package.find(params[:id])
    @fields=Package.show_fields
  end

  def new_attachment
    @owner=Package.find(params[:id]).becomes(Package)
    @attachment=Attachment.new
    render :partial=>"shared/attachment_modal"
  end

  def close
    package=Package.find(params[:id])
    Transaction.build_for(
      package,
      'Complete',
      current_user.id
    )
    package.status="Completed"
    package.date_complete=Time.now.to_date
    if package.save
      redirect_to package_path(package)
    end
  end

  def print
      @package=Package.find(params[:id])
      html=render_to_string(:template=>"/packages/print.html.erb")
      pdf=PDFKit.new(html)
      pdf.stylesheets <<("#{Rails.root}/public/css/bootstrap.css")
      title = ''
      if @package.class.display_name == "VP/Part 5 IM Package"
          title = "VP/Part5"
        elsif @package.class.display_name == "Job Aid Package"
          title = "Job_Aid"
        elsif @package.class.display_name == "Framework IM Package"
          title = "Framework"
        end
      send_data pdf.to_pdf, :filename => "#{title}_Package_##{@package.get_id}.pdf"
    end

  def index
    @ims = true
    @table=Package
    if params[:status].present?
      @records=@table.within_timerange(params[:start_date], params[:end_date]).where("status=?",params[:status])
    else
      @records=@table.within_timerange(params[:start_date], params[:end_date])
    end
    handle_search
    @headers=@table.get_headers
    @table_name="packages"
  end


  def get_agenda
    @package=Package.find(params[:id])
    @meeting=Object.const_get(@package.class.meeting_type).find(params[:meeting])
    @headers=SmsAgenda.get_headers
    @status=SmsAgenda.get_status
    @tof={"Yes"=>true,"No"=>false}
    @accept_deline={"Accepted"=>true,"Declined"=>false}
    render :partial=>"agenda"
  end

  def carryover
    package=Package.find(params[:id])
    if package.status=="Awaiting Review"
      package.status="Open"
    end
    package.meeting_id=nil
    package.save
    render status: 200
  end

  def destroy
    @type = Package.find(params[:id]).type
      Package.find(params[:id]).destroy
      redirect_to packages_path(:type=>@type), flash: {danger: "#{@type} ##{params[:id]} deleted."}
      #redirect_to root_url
    end

   def new_minutes
    @owner=Package.find(params[:id]).becomes(Package)
    @meeting = Meeting.find(params[:meeting])
    render :partial=>"shared/add_minutes"
  end

end
