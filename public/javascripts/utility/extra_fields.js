$(document).ready(function(){

	var submit_btn;

	$(":submit").click(function(){
		submit_btn = $(this).val();
	});

	$("form").on('submit',function(event){
		if(submit_btn == "Save for Later"){
			buttons.removeAttr('data-disable-with');
		}else{
			var error = false;
			var result = true;
			$(".required_field").css('border-color', '');
			$(this).find('.required_field').each(function(){
				if ($(this).val() == ""){
					error = true;
					result = false;
					$(this).css('border-color', 'red');  
					event.preventDefault();
				}
			});
			if (error){
				swal({
					title: "Please fill in all required fields.",
					type: "error",
				});
				return result;
			}
		}
	});


	$(".non_dup").on('change',function(){
		new_val=$(this).val();
		uid=$(this).attr('id')
		$(".non_dup").each(function(){
			if ($(this).val() == new_val&&$(this).attr('id')!=uid){
				 $(this).val('');   
			}
		});
	});
});



