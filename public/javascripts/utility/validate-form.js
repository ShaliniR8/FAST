$(document).ready(function(){
	removeOptions();
});
function removeOptions(){
	$('.date-type-select').each(function(){
		if($(this).val() == "text" || $(this).val() == "textarea" || $(this).val() == "employee" || $(this).val() == "airport"){
			$(this).closest('.field-area').children('.field-options').hide();
		}else if($(this).val() == "checkbox" || $(this).val() == "radio"){
			$(this).closest('.field-area').children('.field-required').hide();
		}else{
			$(this).closest('.field-area').children('.field-options').show();
			$(this).closest('.field-area').children('.field-required').show();
		}
	});
	$('.date-type-select').on('change',function(){
		$(this).closest('.field-area').children('.field-options').show();
		$(this).closest('.field-area').children('.field-required').show();
		if($(this).val() == "text" || $(this).val() == "textarea" || $(this).val() == "employee" || $(this).val() == "airport"){
			$(this).closest('.field-area').children('.field-options').hide();
		}else if($(this).val() == "checkbox" || $(this).val() == "radio"){
			$(this).closest('.field-area').children('.field-required').hide();
		}else{
			$(this).closest('.field-area').children('.field-options').show();
			$(this).closest('.field-area').children('.field-required').show();
		}
	});


}