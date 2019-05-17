class AuditFinding < Finding
  belongs_to :owner,foreign_key:"audit_id",class_name:"Audit"


  def get_source
    "<a style='font-weight:bold' href='/audits/#{owner.id}'>
      Audit ##{owner.id}
    </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
  end

end
