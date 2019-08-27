$(document).ready(function(){
	var options_hash
  $.getJSON(`${window.location.href.split('/').slice(0, 3).join('/')}/javascripts/templates/losav_options.json`, function(options) {
    options_hash = options
    var classNames = ['threat', 'err']
    for (className of classNames) {
      $(`.${className}`).each(function() {
        var rowId = $(this).attr('id')
        var childField = $(`.sub${className}#${rowId}`)
        if ($(this).val() !== '') {
          potential_options = options_hash[$(this).val()];
          childField.html(make_options(potential_options));

          var selected_value = $(this).closest("td").next().next().find(".select_value").val();
          childField.val(selected_value);
        } else {
          childField.html('');
        } 
      });
    }
  })

	$('.master').on('change',function(){
		if ($(this).val() != ""){
			$('.follow#' + $(this).attr('id')).each(function(){
				$(this).show();
				$(this).closest('.form-group').find('label').show();				
			})
		}
	});

	$('.threat').on('change',function(){
		if ($(this).val() != ""){
			potential_options = options_hash[$(this).val()];
			$('.subthreat#' + $(this).attr('id')).html(make_options(potential_options));
		}else{
			$('.subthreat#' + $(this).attr('id')).html("");
		}
	});
	$('.err').on('change',function(){
		if ($(this).val() != ""){
			potential_options = options_hash[$(this).val()];
			$('.suberr#' + $(this).attr('id')).html(make_options(potential_options));
		}else{
			$('.suberr#' + $(this).attr('id')).html("");
		}
	});
});


function make_options(options){
	result = "<option></option>";
	length = options.length
	for (i = 0; i < length; i++){
		result += "<option value=\""+options[i]+"\">"+options[i]+"</option>"
	}
	return result;
}

