class DocumentsController < ApplicationController

  before_filter :login_required

  def index
    @documents = Document.find(:all)
  end

  def new
    @document = Document.new
    @category_options = Document.get_categories
    @file_options = ['File Upload', 'External Link']
    if BaseConfig.airline[:has_mobile_app]
      @file_options.push('File Upload (Tracked)')
    end
    render :partial =>"new"
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    redirect_to documents_path
  end

  def create
    @document = Document.new(params[:document])
    @document.save
    redirect_to documents_path
  end

  def download
    @document = Document.find(params[:id])
    if (@document.tracking_identifier.present?)
      # values are from Document.get_tracking_identifiers
      case @document.tracking_identifier
      when 'Android'
        current_user.update_attributes({ :android_version => @document.version })
      end
    end
    redirect_to params[:url]
  end

  def revision_history
  end

  def user_guides
  end

  def load_content
    render :partial => "documents/user_guides/#{params[:href]}"
  end

end
