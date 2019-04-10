module QueryStatementsHelper
	def fields_select_with_categories(categories)
		categories.map do |group|
          option_tags = options_for_select(group.analytic_fields.map{ |c| [c.label, c.id] })
          content_tag(:optgroup, option_tags, label: group.title, "data-template_id"=>group.templates_id,:style=>"display:none")
        end.join.html_safe
	end


	def fields_select_all(categories)
		options = Hash.new
		categories.each do |category|
			fields = category.fields
			fields.each do |field| 
				if options[field.label] != nil
					options[field.label] = options[field.label] + 1;
				else
					options[field.label] = 1;
				end
			end
		end
		options_for_select(options.keys.sort)
	end
end
