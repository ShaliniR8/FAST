class Field < ActiveRecord::Base
	
	has_many :record_fields,		 	:foreign_key => "fields_id",				:class_name => "RecordField"
	has_many :submission_fields, 	:foreign_key => "fields_id",				:class_name => "SubmissionField"
	has_many :section_fields, 	 	:foreign_key => "field_id", 				:class_name => "SectionField"
	has_many :nested_fields, 		 	:foreign_key => "nested_field_id",  :class_name => "Field"
	

	belongs_to :category, 				:foreign_key => "categories_id", 		:class_name => "Category"
	belongs_to :map_field, 				:foreign_key => "map_id", 					:class_name => "Field"
	belongs_to :parent_field, 		:foreign_key => "nested_field_id", 	:class_name => "Field"


	def export_label
		if self.label.length>20
			result=self.label.split(' ').last(5).join('_').downcase
			result
		else
			result=self.label.tr(' ','_').downcase
			result
		end
	end



	def get_label
		if self.show_label
			self.label
		else
			nil
		end
	end



	def custom_id
		self.category.id.to_s+"-"+self.id.to_s
	end



	def self.getDisplay_type
		{
			"Airport Select Field" 				=> "airport",
			"Employee Select Field" 				=> "employee",
			"Autocomplete Field" 				=> "datalist",
			"Text Field"			=> "text",
			#{}"Radio Button"		=> "radio",
			"Drop Down Menu"	=> "dropdown",
			"Check Boxes"				=> "checkbox",
			"Text Area"				=> "textarea"			
		}
	end



	def self.getData_type
		{
			"Text"					=> "text",
			"Date"					=> "date",
			"Date/Time"			=> "datetime",
			# "Numeric (Integer)"=>"int",
			# "Numeric (Decimal)"=>"float",
			# "Y/N"  =>"bool",
			"Time Zone"			=> "timezone"
		}
	end

	

	def get_size
		case self.data_type
		when 'text'
			'Text : Unlimited'
		when 'date'
			'Date : String : 20'
		when 'datetime'
			'Date/Time : String : 20'
		when 'timezone'
			'Timezone : String : 10'
		when 'int'
			'Integer : 10'
		when 'bool'
			'String : 255'
		else 
			'Unknown'
		end
	end



	def self.getDisplay_size
		(1..12).to_a
	end



	def getOptions2()
		if self.data_type=="timezone"
			["EDT","CDT","EST","CST","MDT","MST","PDT","PST","AKDT","AKST"]
		else
			self.options.split(";")
		end
	end



	def getOptions()
		if self.data_type=="timezone"
			["Z","NZDT","IDLE","NZST","NZT","AESST","ACSST","CADT","SADT","AEST","CHST","EAST","GST",
			 "LIGT","SAST","CAST","AWSST","JST","KST","MHT","WDT","MT","AWST","CCT","WADT","WST",
			 "JT","ALMST","WAST","CXT","MMT","ALMT","MAWT","IOT","MVT","TFT","AFT","MUT","RET",
			 "SCT","IRT","IT","EAT","BT","EETDST","HMT","BDST","CEST","CETDST","EET","FWT","IST",
			 "MEST","METDST","SST","BST","CET","DNT","FST","MET","MEWT","MEZ","NOR","SET","SWT",
			 "WETDST","GMT","UT","UTC","ZULU","WET","WAT","FNST","FNT","BRST","NDT","ADT","AWT",
			 "BRT","NFT:NST","AST","ACST","EDT","ACT","CDT","EST","CST","MDT","MST","PDT","AKDT",
			 "PST","YDT","AKST","HDT","YST","MART","AHST","HST","CAT","NT","IDLW"]
		else
			self.options.split(";")
		end
	end



	def get_html_tag
		"#{self.category.title.downcase.parameterize}_#{self.label.downcase.parameterize}"
	end



	def get_field_data_type
		"#{custom_id}-#{data_type}"
	end



end
