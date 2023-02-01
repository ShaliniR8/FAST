class UsersController < ApplicationController
  # before_filter :login_required
  before_filter :oauth_load # Kaushik Mahorker KM
  include Concerns::Mobile # used for mobile actions

  def index
    unless current_user.global_admin?
      flash[:notice] = 'Only Administrators can view all the user accounts'
      redirect_to root_url
      return
    end

    @disabled = (params[:disabled] || false)

    @headers = User.get_meta_fields('index')
    # @headers = User.get_headers_table

    @records = User.where({airport: current_user.airport})

    if @disabled.present?
      @records = @records.where('disable = ?', 1)
      @statistics = [{ :label => 'Disabled Users', :value => @records.count }]
      @title = "Disabled Users"
    else
      @records = @records.where('disable != ? OR disable IS ?', 1, nil)
      @statistics = [{ :label => 'Active Users', :value => @records.count }]
      @title = "Active Users"
    end

    if CONFIG::GENERAL[:has_mobile_app]
      latest_version = latest_android_version
      android_users = @records.where('android_version > ?', 0)
      latest_android_users = @records.where({android_version: latest_version})

      if @disabled.present?
        @statistics.concat([
          { :label => 'Latest Android Version', :value => latest_version},
          { :label => 'Up-to-Date Disabled Android Users', :value => latest_android_users.count },
          { :label => 'Total Disabled Android Users', :value => android_users.count },
        ])
      else
        @statistics.concat([
          { :label => 'Latest Android Version', :value => latest_version},
          { :label => 'Up-to-Date Android Users', :value => latest_android_users.count },
          { :label => 'Total Android Users', :value => android_users.count },
        ])
      end
    end
    @table = Object.const_get("User")
    @table_name = "users"
    #@users.keep_if{|u| !u.disable}
  end



  def new
    @levels = User.get_levels
    @action = 'new'
    unless current_user.global_admin?
      flash[:notice] = 'Only Global Administrators can create new accounts.'
      redirect_to root_url
      return
    end
    @user = User.new
    @user.airport = current_user.airport
    @authorized = current_user.global_admin?
    @departments = CONFIG.custom_options['Departments']
  end



  def show
    @user = User.find(params[:id])
    if !((current_user.id == @user.id || current_user.global_admin?) and @user.airport == current_user.airport)
      flash[:notice] = 'Only Administrators can view another user\'s account.'
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
    user.privileges_last_updated = DateTime.now
    user.save!
    redirect_to user_path(user), flash: {success: "Privileges updated."}
  end



  def create
    unless current_user.global_admin?
      flash[:notice] = 'Only Administrators can create new accounts.'
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
      @user.sync_user_hook if CONFIG::GENERAL[:external_link]
      flash[:success] = "Account has been created."
      redirect_to user_path(@user)
    else
      @authorized = true
      @action = 'new'
      @levels = User.get_levels
      @departments = CONFIG.custom_options['Departments']
      flash[:error] = @user.errors.full_messages
      render :action => 'new'
    end
  end



  def edit
    @levels = User.get_levels
    @authorized = current_user.global_admin?
    @action = 'edit'
    @users = User.find(:all, :conditions => {:airport => current_user.airport})
    match_id = params[:id]
    @user = User.find(params[:id])
    @departments = CONFIG.custom_options['Departments']
  end



  def self_edit
    @authorized = true
    @action = 'self_edit'
    @user = User.find(params[:id])
  end



  def change_password
    @user = User.find(params[:id])
    @title = "#{@user.first_name} #{@user.last_name}"
    if !((current_user.id == @user.id) && @user.airport == current_user.airport)
      flash[:notice] = 'To change a user\'s password, access their account from the grid'
      redirect_to root_url
      return
    end
  end


  def access_level
    @user = User.find(params[:id])
  end

  def external_link
    @user = User.find(params[:id])
    link = CONFIG.external_link(@user)

    if link.present?
      redirect_to link
    else
      redirect_to @user, alert: 'External Account could not be found.'
    end
  end

  def update
    @user = User.find(params[:id])
    prev_email = @user.email
    @departments = CONFIG.custom_options['Departments']

    # User entered wrong password, only works for the self edit page right now
    if !@user.matching_password?(params[:pw])
      if params[:page].present?
        if params[:page] == 'self_edit'
          flash[:error] = 'Incorrect Password.'
          @authorized = true
          @action = 'self_edit'
          @levels = User.get_levels
          render :action => 'self_edit'
          return

        elsif params[:page] == 'change_password'
          flash[:error] = 'Incorrect Password/Confirmation.'
          @authorized = true
          @action = 'change_password'
          @levels = User.get_levels
          render :action => 'change_password'
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

        @user.sync_user_hook(prev_email) if CONFIG::GENERAL[:external_link]

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
    @user.disable = @user.disable ? 0 : 1
    @user.save
    status = @user.disable ? "Disabled" : "Enabled"
    redirect_to user_path(@user), flash: { warning: "User has been #{status}."}
  end


  def simulate
    @user = User.find(params[:id])
    if current_user.global_admin?
      session[:simulated_id] = @user.id
      define_session_permissions
    else
      flash[:error] = "Only Administrators may simulate Accounts"
    end
    redirect_to choose_module_home_index_path
  end


  def stop_simulation
    @user = User.find(params[:id])
    session.delete(:simulated_id)
    define_session_permissions
    redirect_to user_path(@user)
  end


  def user_json_request
    respond_to do |format|
      format.html
      format.json {
        render json: User.select('full_name, id').order(:full_name).uniq(&:full_name).collect{|u| u.attributes}
      }
    end
  end

  private

  def build_module_access
    ['p139', 'arff', 'fuel', 'wildlife', 'notam', 'bird', 'storm', 'opslog', 'maint', 'vehicle', 'audit'].select do |name|
      params[:"module_#{name}"].to_i == 1
    end.join(',')
  end

end
