# All Safety Promotion-specific models inherit from this object:
  # This provides module-specific methods for Safety Promotion
  # Any new methods added here are available to all Safety Promotion Objects
module Sp
  class SafetyPromotionBase < ProsafetBase

    self.abstract_class = true

    def get_id
      return id
    end

    def append_transaction(action, uid, content)
      Transaction.build_for(
          self,
          action,
          uid,
          content
        )
    end

    def get_creator
      created_by.full_name rescue ""
    end

    def get_publish_date
      publish_date.strftime("%Y-%m-%d") rescue ""
    end

    def get_complete_by_date
      complete_by_date.strftime("%Y-%m-%d") rescue ""
    end

    def get_user_completion_date(uid)
      completion_arr = completions.map {|c| c.user_id == uid ? c.complete_date : nil}.keep_if{|x| !x.nil?}
      completion_arr.last.strftime("%Y-%m-%d") rescue ""
    end

    def get_archive_date
      archive_date.strftime("%Y-%m-%d") rescue ""
    end

    def has_user(user)
      distro_list = DistributionList.preload(:distribution_list_connections).where(id: distribution_list.split(',')).map{|d| d.get_user_ids}.flatten rescue []
      return user.id == user_id || distro_list.include?(user.id)
    end

    def get_tooltip
      "#{self.class.name} #{title}"
    end

  end
end
