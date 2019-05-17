class RiskControlDescription < Cause
  belongs_to :owner, foreign_key: "owner_id", class_name: "RiskControl"



  def get_value
    if self.value=="true"
      "Yes"
    else
      self.value
    end
  end

  def get_attr
    self.class.categories[self.category].each do |c|
      if c[:name]==self.send('attr')
        return c[:title].present? ? c[:title] : c[:name].titleize
      end
    end
  end

  def self.categories
        ({
            "Narrative" => [
              {name: "Narrative",                          type: "text_area"},
          ]
    }).sort.to_h
  end
end
