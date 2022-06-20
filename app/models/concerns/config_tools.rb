module ConfigTools
  extend ActiveSupport::Concern

  included do
    # priv_check is a shorthand for user.has_access for actions[:access] procs in HIERARCHY- do not alter
    def self.priv_check
      proc { |owner, user, action, admin=true, strict=false|
        
        if owner.class.name == 'Meeting' && owner.type == 'SrmMeeting'
          rule_name = 'srm_meetings'
        else
          rule_name = owner.rule_name
        end

        user.has_access(rule_name, action, admin: admin, strict: strict)
      }
    end

    def self.super_proc(obj,act)
      self.superclass::HIERARCHY[:objects][obj][:actions][act][:access]
    end

  end

  # References to all default actions and metadatas for all classes
  DICTIONARY = DefaultDictionary

end
