class UsersController < ApplicationController
  # before_filter :login_required
  before_filter :oauth_load # Kaushik Mahorker KM


  def index
    if (current_user.level != "Admin")
      flash[:notice] = "Only Administrators can view all the user accounts"
      redirect_to root_url
      return
    end

    @headers = User.get_headers_table
    @records = User.where({airport: current_user.airport})

    active_users = @records.where('disable = ? OR disable IS ?', false, nil)
    @statistics = [{ :label => 'Active Users', :value => active_users.count }]

    if BaseConfig.airline[:has_mobile_app]
      latest_version = latest_android_version
      android_users = active_users.where('android_version > ?', 0)
      latest_android_users = active_users.where({android_version: latest_version})

      @statistics.concat([
        { :label => 'Latest Android Version', :value => latest_version},
        { :label => 'Up-to-Date Android Users', :value => latest_android_users.count },
        { :label => 'Total Android Users', :value => android_users.count },
      ])
    end

    @table_name = "users"
    @title = "Users"
    #@users.keep_if{|u| !u.disable}
  end



  def new
    @levels = User.get_levels
    @action = "new"
    if (current_user.level != "Admin")
      flash[:notice] = "Only Administrators can create new accounts."
      redirect_to root_url
      return
    end
    @user = User.new
    @user.airport = current_user.airport
    if current_user.level != "Admin"
      @authorized = false
    else
      @authorized = true
    end
  end



  def show
    @user = User.find(params[:id])
    if !((current_user.id == @user.id or current_user.level == "Admin") and @user.airport == current_user.airport)
      flash[:notice] = "Only Administrators can view another user's account."
      redirect_to root_url
      return
    end
  end



  def edit_privilege
    @user = User.find(params[:id])
    @headers = Privilege.get_headers
    @roles = Privilege.find(:all)
  end



  def update_privilege
    user = User.find(params[:id])
    if params[:roles].present?
      user.roles.each do |a|
        if !params[:roles].include? a.privilege.id.to_s
          a.destroy
        end
      end
      params[:roles].each do |r|
        if !user.privilege_ids.include? r.to_i
          role = Role.new
          role.privileges_id = r
          role.users_id=params[:id]
          role.save
        end
      end
    else
      user.roles.each do |a|
        a.destroy
      end
    end
    redirect_to user_path(user), flash: {success: "Privileges updated."}
  end



  def create
    if (current_user.level != "Admin")
      flash[:notice] = "Only Administrators can create new accounts."
      redirect_to root_url
      return
    end

    @user = User.new(params[:user]) do |u|
      u.full_name = u.first_name + " " + u.last_name
      u.module_access = build_module_access
      u.airline = u.airport
    end

    # assign unique_id if column exists and value is unique in column
    if ActiveRecord::Base.connection.column_exists?(:users, :unique_id)
      loop do
        @user.unique_id = SecureRandom.uuid
        break if not User.exists?(unique_id: @user.unique_id)
      end
    end
    if @user.save
      flash[:success] = "Account has been created."
      redirect_to user_path(@user)
    else
      @authorized = true
      @action = "new"
      @levels = User.get_levels
      flash[:error] = @user.errors.full_messages
      render :action => 'new'
    end
  end



  def edit
    @levels=User.get_levels
    Rails.logger.debug ("In edit")
      # if (current_user.level != "Admin")
      #     flash[:notice] = "Only Administrators can edit users"
      #     redirect_to root_url
      #     return
      # end
    if current_user.level != "Admin"
      @authorized = false
    else
      @authorized = true
    end
    @action = "edit"
    @users = User.find(:all, :conditions => {:airport => current_user.airport})
    match_id = params[:id]
    @user = User.find(params[:id])
    #@user = User.find(:all, :conditions => {:full_name => @users[match_id.to_i-1].full_name})
  end



  def self_edit
    @authorized = true
    @action = "self_edit"
    Rails.logger.debug ("In self edit")
    @user = User.find(params[:id])
  end



  def change_password
    Rails.logger.debug ("In change password")
    @user = User.find(params[:id])
    @title = @user.first_name + " " + @user.last_name
    if !((current_user.id == @user.id) and @user.airport == current_user.airport)
      flash[:notice] = "To change a user's password, access their account from the grid"
      redirect_to root_url
      return
    end
  end



  def access_level
    @user = User.find(params[:id])
  end



  def update
    @user = User.find(params[:id])
    Rails.logger.debug ("In update")

    # User entered wrong password, only works for the self edit page right now
    if !@user.matching_password?(params[:pw])
      if params[:page].present?
        if params[:page] == "self_edit"
          flash[:error] = "Incorrect Password."
          @authorized = true
          @action = "self_edit"
          @levels = User.get_levels
          render :action => "self_edit"
          #redirect_to self_edit_user_path(current_user)
          return

        elsif params[:page] == "change_password"
          #redirect_to change_password_user_path(current_user)
          flash[:error] = "Incorrect Password/Confirmation."
          @authorized = true
          @action = "change_password"
          @levels = User.get_levels
          render :action => "change_password"
          return
        end
      end
    end

    respond_to do |format|
      if (@user.update_attributes(params[:user]))
        @user.tap do |u|
          u.full_name = u.first_name + " " + u.last_name
          if params[:page].blank? || (params[:page] != "change_password" && params[:page] != "self_edit")
          end
          if User.display[:position]
            u.role = params[:user][:role]
          end
        end
        @user.save
        format.html {redirect_to(@user, :flash => {:success => "Changes saved."})}
        format.xml  { head :ok }
      else
        if params[:page].present?
          if params[:page] == "self_edit"
            #redirect_to self_edit_user_path(@user)
            flash[:error] = @user.errors.full_messages
            @authorized = true
            @action = "self_edit"
            @levels = User.get_levels
            render :action => "self_edit"
            return
          elsif params[:page] == "change_password"
            flash[:error] = @user.errors.full_messages
            @authorized = true
            @action = "change_password"
            @levels = User.get_levels
            render :action => "change_password"
            return
          else
            #redirect_to edit_user_path(@user)
            flash[:error] = @user.errors.full_messages
            @authorized = true
            @action = "edit"
            @levels = User.get_levels
            render :action => "edit"
            return
          end
        else
          #redirect_to edit_user_path(@user)
          flash[:error] = @user.errors.full_messages
          @authorized = true
          @action = "edit"
          @levels = User.get_levels
          render :action => "edit"
          return
        end
      end
    end
  end



  def disable
    @user = User.find(params[:id])
    @user.disable = @user.disable ? false : true
    @user.save
    status = @user.disable ? "disabled" : "enabled"
    redirect_to user_path(@user), flash: { warning: "User has been #{status}."}
  end



  def simulate
    @user = User.find(params[:id])
    if current_user.admin?
      session[:simulated_id] = @user.id
    else
      flash[:error] = "Only Administrators may simulate Accounts"
    end
    redirect_to choose_module_home_index_path
  end



  def stop_simulation
    @user = User.find(params[:id])
    session.delete(:simulated_id)
    redirect_to user_path(@user)
  end



  # --------- BELOW ARE EVERYTHING ADDED FOR PROSAFET APP
  # New methods for ProSafeT App 2019 by SM
  def get_user
    # Get only the data that we need from the user
    mobile_user_info = current_user.as_json(only: [:id, :full_name, :email])['user']

    # Get which modules the user has access to
    mobile_user_info[:mobile_module_access] = [
      'ASAP',
      'Safety Assurance',
      # 'SMS IM',
      # 'Safety Risk Management',
    ].select{|module_name| current_user.has_access(module_name, 'module')}

    # Get and parse the user's notices
    mobile_user_info[:notices] = current_user.notices.as_json(only: [
      :id,
      :content,
    ]).map do |notice|
      notice = notice['notice']
      notice['owner_id'] = nil
      notice['type'] = nil
      content = notice['content']
      extracted_uri = URI.extract(content, /http(s)?/)[0]
      if extracted_uri.present?
        parsed_content = extracted_uri.chop.split('/').reverse
        notice['owner_id'] = parsed_content[0]
        notice['type'] = parsed_content[1]
      end
      notice['content'] = content.gsub(/<a.*/, '').strip
      notice
    end

    # mobile_user_info[:submissions] = current_user.submissions.as_json(only: [
    #   :id,
    #   :templates_id,
    #   :description,
    #   :event_date,
    #   :completed
    # ]).map {|submission| submission['submission']}

    render :json => mobile_user_info
  end

  def get_audits
    audits = Audit.all

    if !current_user.admin? && !current_user.has_access('audits', 'admin')
      audits = Audit.where('responsible_user_id = :id OR approver_id = :id', { id: current_user[:id] })
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
    end

    # Convert to id map for fast audit lookup
    audits = audits
      .as_json(only: [:id, :status, :title, :completion])
      .map {|audit| audit['audit']}
      .reduce({}) { |audits, audit| audits.merge({ audit['id'] => audit }) }

    render :json => audits
  end

   # following method added. BP Jul 14 2017
  # Added if statement for OAuth compatibiltiy KM Jul 17 2017
  def get_json
    @date = params[:date]
    if current_token != nil
      @user = current_token.user
    else
      @user = current_user
    end
    @submissions = current_user.submissions.where("created_at > ?",@date)
    stream = render_to_string(:template=>"users/get_json.js.erb" )
    send_data(stream, :type=>"json", :disposition => "inline")
  end

  #added by BP Aug 8 2017. Used to get all submissions with detailed fields from current user
  def submission_json
    if current_token != nil
      @user = current_token.user
    else
      @user = current_user
    end
    @submissions = Submission.find(:all, :conditions => [ "event_date > ?",'2017-8-11 12:00:00'])
    stream = render_to_string(:template=>"users/submission_json.js.erb" )
    send_data(stream, :type=>"json", :disposition => "inline")
  end


  def notices_json
    if current_token != nil
      @user = current_token.user
    else
      @user = current_user
    end
    @notices = @user.get_notices
    stream = render_to_string(:template=>"users/notices_json.js.erb" )
    send_data(stream, :type=>"json", :disposition => "inline")
  end






  private

  def build_module_access
    ['p139', 'arff', 'fuel', 'wildlife', 'notam', 'bird', 'storm', 'opslog', 'maint', 'vehicle', 'audit'].select do |name|
      params[:"module_#{name}"].to_i == 1
    end.join(',')
  end



end
