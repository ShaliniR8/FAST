  def datalist(f,field,select_options,options = {})
    result=f.text_field field,options.merge(:list=>"#{field}_list")
    result+=("<datalist id='#{field}_list'>"+select_options+"</datalist>").html_safe
    result.html_safe
  end