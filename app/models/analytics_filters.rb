module AnalyticsFilters


  def can_be_accessed(current_user)
    templates = Template.where(:name => current_user.get_all_templates).map(&:id)
    templates = Template.all.map(&:id) if current_user.has_access(self.name.downcase.pluralize, 'admin', admin: true, strict: true)
    if self.to_s == "Submission"
      preload(:template).where("submissions.templates_id IN (?) OR submissions.user_id = ?", templates, current_user.id)
    else
      preload(:template).where("records.templates_id IN (?) OR records.users_id = ?", templates, current_user.id)
    end
  end



  def within_timerange(start_date, end_date)
    begin
      start_date = Time.zone.parse(start_date) if start_date.is_a?(String)
      end_date = Time.zone.parse(end_date)     if end_date.is_a?(String)
    rescue
      Rails.logger.debug "within timemrange failed"
      return scoped
    end
    Rails.logger.debug "start=#{start_date}, end=#{end_date}"
    return scoped if start_date.nil? || end_date.nil?
    if self.to_s == "Submission" || self.to_s == "Record"
      return where("#{table_name}.event_date >= ? && #{table_name}.event_date <= ?", start_date.utc, end_date.utc)
    else
      return where("#{table_name}.created_at >= ? && #{table_name}.created_at <= ?", start_date.utc, end_date.utc)
    end
  end

  def by_emp_group(emp_group)
    if emp_group.nil?
      return scoped
    else
      return includes(:template).where("templates.emp_group = ?", emp_group)
    end
  end

  def by_emp_groups(groups)
    unless groups
      return scoped
    else
      return includes(:template).where("templates.emp_group in (?)", groups)
    end
  end

  def filter_array_by_timerange(array, start_date, end_date)
    if start_date && end_date
      begin
        start_date = Time.zone.parse(start_date)
        end_date = Time.zone.parse(end_date)
      rescue
        Rails.logger.error "Could not parse start_date or end_date parameters"
        return array
      else
        if start_date && end_date
          return array.select{|item| item.created_at >= start_date && item.created_at <= end_date }
        else
          return array
        end
      end
    else
      return array
    end
  end


  def filter_array_by_emp_groups(array, groups)
    if groups
      return array.select{|item| groups.include?(item.template.emp_group)}
    else
      return array
    end
  end

end
