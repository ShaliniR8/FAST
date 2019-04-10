var employee_table;
function build_user_table(){
	employee_table = $('#users').DataTable({
		"aLengthMenu": [[5, 10, 15, -1], [5, 10, 15, "All"]],
		"iDisplayLength": 5
	});
}
function clear_user_table(){
	employee_table.destroy();
}


$(document).ready(function(){
	$(window).resize();
	build_user_table();
	$(this).find(".emp_button").each(function(index, item){
		$(item).on("click", function(){
			var field_id = $(this).prop('id');
			$(".emp_modal").show();
			clear_user_table();
			$("tbody tr").unbind();
			$(".close").unbind();
			$("tbody tr").on("click", function(){
				$(item).parent().parent().find("#emp" + field_id).val($(this).find("td").eq(3).text());
				$(item).parent().parent().find("#employee-select"+field_id).val($(this).find("td").eq(0).text());
				$('#emp_div').hide();
				$('.emp_modal').modal('toggle');
			});
			$('.close').on('click',function(){
				$(item).parent().parent().find("#emp"+field_id).val("");
				$(item).parent().parent().find("#employee-select"+field_id).val("");
				$('#emp_div').hide();
			});
			build_user_table();
		});

	});

	
});