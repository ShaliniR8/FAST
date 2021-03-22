class Category < ActiveRecord::Base
	belongs_to :template, foreign_key: "templates_id", class_name: "Template"
	has_many :fields, foreign_key: "categories_id", class_name: "Field", :dependent => :destroy, :order => 'field_order ASC'
  accepts_nested_attributes_for :fields, :reject_if => :checkbox_or_radio_invalid?


  scope :active, -> {where(deleted: 0).order(category_order: :asc)}

	def updated
		result = fields.map(&:updated_at) << updated_at
		result = result.sort.last
		result
	end



	def get_title
		self.title.titleize
	end



	def analytic_fields
		# does not trend text area and time zone, and archived fields
		if !self.deleted
			self.fields
				.where('deleted = 0 and display_type != ? and !(label like ?)',
				"textarea",
				"\%Time Zone%")
		else
			[]
		end
	end



	def self.getColor
		{
			"Grey"=>"panel-default",
			"Light Blue"=>"panel-info",
			"Green"=>"panel-success",
			"Red"=>"panel-danger",
			"Deep Blue"=>"panel-primary",
			"Orange"=>"panel-warning",
			"Pink"=>"panel-pink",
			"Violet"=>"panel-violet",
			"Black"=>"panel-black",
			"White"=>"panel-white"
		}
	end



	def custom_id
		self.template.id.to_s+"-"+self.id.to_s
	end



	# Check if category needs to be shown
	def not_empty_for(record)
		fields_id = fields.map(&:id)
		if record.class.name.demodulize == 'Record'
			field_values = RecordField.where("records_id = ? and fields_id in (?) and value <> ?",
				record.id,
				fields_id,
				'')
		elsif record.class.name.demodulize == 'Submission'
			field_values = SubmissionField.where("submissions_id = ? and fields_id in (?) and value <> ?",
				record.id,
				fields_id,
				'')
		else
			false
		end
		field_values.length > 0
	end



	def record_fields(record)
		fields_id = fields.map(&:id)
		if record.class.name.demodulize == 'Record'
			table = Object.const_get('RecordField')
		elsif record.class.name.demodulize == 'Submission'
			table = Object.const_get('SubmissionField')
		else
			false
		end
		field_values = table
			.where("records_id = ? and fields_id in (?) and value <> ?",
			record.id,
			fields_id,
			'')
		field_values
	end




	def not_all_empty_for(records)
		self.fields.each do |f|
			records.each do |record|
				if record.class.name.demodulize=="Record"
					rec=record.record_fields.where("fields_id=?",f.id).first
					value=rec.present? ? rec.value : nil
					if value.present?
						return true
					end
				else
					rec=record.submission_fields.where("fields_id=?",f.id).first
					value=rec.present? ? rec.value : nil
					if value.present?
						return true
					end
				end
			end
		end
		false
	end

  def checkbox_or_radio_invalid?(field)
    if field[:required] == true
      case field[:display_type]
      when 'checkbox'
        return true unless field[:max_options].present? && field[:max_options].to_i >= 1 && field[:options].present?
        return false if field[:options].split(';').size().to_i >= field[:max_options].to_i
        return true
      when 'radio'
        return false if field[:options].split(';').size().to_i >= 1
        return true
      else
        return false
      end
    else
      return false
    end
  end
end
