module ConfigTools
  # priv_check is a shorthand for user.has_access for actions[:access] procs in HIERARCHY- do not alter
  priv_check = proc { |owner, user, action, admin=true, strict=false|
    user.has_access(owner.class.titleize.downcase, action, admin: admin, strict: strict)
  }

  # References to all default actions and metadatas for all classes
  DICTIONARY = DefaultDictionary

end
