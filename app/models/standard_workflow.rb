module StandardWorkflow
  # This set of terms follow the expectations that the extending model follows the standard workflow:
  #  New -> Assigned -> Completed -> Approved
  # Include these into a model with the following:
  #  include StandardWorkflow

  # These can all be overridden by defining them within the model and using the 'super' method:
  # def can_|___|
  #   super
  # end
  # Or by using the provide arguments: form_conds overrides the normal form state requirements, and
  # user_conds overrides the normal user state requirements


  def can_assign?(user, form_conds: false, user_conds: false)
    form_confirmed = self.status == 'New' || form_conds
    user_confirmed = [self.created_by_id, self.approver_id].include?(user.id) ||
      has_admin_rights?(user) ||
      user_conds
    form_confirmed && user_confirmed
  end

  def can_complete?(user, form_conds: false, user_conds: false)
    form_confirmed = self.status == 'Assigned' || form_conds
    user_confirmed = [self.created_by_id, self.responsible_user_id].include?(user.id) ||
      has_admin_rights?(user) ||
      user_conds
    form_confirmed && user_confirmed
  end

  def can_approve?(user, form_conds: false, user_conds: false)
    form_confirmed = self.status == 'Pending Approval' || form_conds
    user_confirmed = [self.created_by_id, self.approver_id].include?(user.id) ||
      has_admin_rights?(user) ||
      user_conds
    form_confirmed && user_confirmed
  end

  def can_reopen?(user, form_conds: false, user_conds: false)
    return false unless BaseConfig.airline[:allow_reopen_report]
    form_confirmed = self.status == 'Completed' || form_conds
    user_confirmed = [self.created_by_id].include?(user.id)||
      has_admin_rights?(user) ||
      user_conds
    form_confirmed && user_confirmed
  end

  def can_destroy?(user, form_conds: false, user_conds: false)
    false
  end

# Helper methods

  def permission
    "#{self.class.name.underscore}s"
  end

  def has_admin_rights?(user)
    user.admin? || user.has_access(self.permission, 'admin')
  end

end
