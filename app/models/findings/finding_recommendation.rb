class FindingRecommendation < Recommendation
  belongs_to :finding, foreign_key: "owner_id", class_name:"Finding"

  def owner
    self.finding
  end

  def get_source
    "<a style='font-weight:bold' href='/findings/#{owner.id}'>
      Finding ##{owner.id}
    </a>".html_safe rescue "<b style='color:grey'>N/A</b>".html_safe
  end


end
