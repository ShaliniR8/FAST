// $(document).ready(function(){
// 	$(window).resize();
// 	build_airport_table();
// 	$(this).find(".airport_button").each(function(index, item){
// 		$(item).on("click", function(){
// 			var field_id = $(this).prop('id');
// 			$("#icao_code_select").val("");
// 			$("#airports_table").html("");
// 			$(".airport_modal").show();
// 			$("#search_btn").on("click", function(){
//       			update_airports($(item), field_id);
//     		});
// 		});
// 	});
// });
function build_airport_table(){
    airport_table=$('#airports').DataTable({
      "aLengthMenu": [[5, 10, 15, -1], [5, 10, 15, "All"]],
      "iDisplayLength": 5
    });
  }

  function clear_airport_table(){
    airport_table.destroy();
  }

$(document).ready(function(){
	$(window).resize();
	build_airport_table();
	$(this).find(".airport_button").each(function(index, item){
		$(item).on("click", function(){
			var field_id = $(this).prop('id');
			$(".airport_modal").show();
			clear_airport_table();
			$("tbody tr").unbind();
			$(".close").unbind();
			$("tbody tr").on("click", function(){
				$(item).parent().parent().find("#airport"+field_id).val($(this).find("td").eq(0).text()+";"+$(this).find("td").eq(1).text());
				$(item).parent().parent().find("#airport-select"+field_id).val($(this).find("td").eq(0).text()+";"+$(this).find("td").eq(1).text());
				$('#airport_div').hide();
				$('.airport_modal').modal('toggle');
			});
			$('.close').on('click',function(){
				$(item).parent().parent().find("#airport"+field_id).val("");
				$(item).parent().parent().find("#airport-select"+field_id).val("");
				$('#airport_div').hide();
			});
			build_airport_table();
		});
	});
});
