$(document).ready(
	function(){
		$(".view_btn").on("click",function(){
			window.open("/records/"+$(this).closest("tr").attr("record"));
		});
		$(".action-btn").on("click",function(){
			var action_table=$(this).closest("table");
			if (action_table.attr('id')=="included"){
				$(this).removeClass("btn-danger").addClass("btn-warning");
				row=$(this).closest("tr").detach();
				$(this).find("span").removeClass("glyphicon-remove").addClass("glyphicon-plus");
				
				if (
					row.is('.flight_date') ||
					row.is('.flight_number') ||
					row.is('.tail_number') ||
					row.is('.departure_airport') ||
					row.is('.arrival_airport') ||
					row.is('.landing_airport') ||
					row.is('.ca') ||
					row.is('.fo') ||
					row.is('.fa_1') ||
					row.is('.fa_2')
				) {
					row.appendTo("#relevant_reports tbody");
					sorttr('relevant_reports');
				} else {
					row.appendTo("#available_reports tbody");
					sorttr('available_reports');
				}

			}else{
				$(this).removeClass("btn-warning").addClass("btn-danger");
				row=$(this).closest("tr").detach();
				$(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-remove");

				row.appendTo("#included tbody");
				sorttr('relevant_reports');
				sorttr('available_reports');
			}
		});
		$('form').on('submit',function(){
			var count = 0;
			var form = $(this);
			$("#included tbody tr").each(function(){
        if(typeof($(this).attr("record")) !== "undefined"){
          form.append('<input type="hidden" name=records['+count+ '] value='+$(this).attr("record")+'>');
          count++;
        }
			});
			$("#relevant_reports tbody tr").each(function(){
        if(typeof($(this).attr("record")) !== "undefined"){
				  form.append('<input type="hidden" name=dettach['+count+ '] value='+$(this).attr("record")+'>');
				  count++;
        }
			});
			$("#available_reports tbody tr").each(function(){
        if(typeof($(this).attr("record")) !== "undefined"){
				  form.append('<input type="hidden" name=dettach['+count+ '] value='+$(this).attr("record")+'>');
				  count++;
        }
			});
			return true;
		});
	}
);
function sorttr(table)
{

	var rows=$(`#${table} tbody tr`).get();
    if ($("#included tbody tr").length)
    {
    	var base_date=Date.parse($("#included tbody tr").eq(0).find('td').eq(1).text());
		rows.sort(function(row1,row2){
			var diff1=Math.abs(base_date-Date.parse($(row1).find('td').eq(1).text()));
			var diff2=Math.abs(base_date-Date.parse($(row2).find('td').eq(1).text()));
			if  (diff1<diff2){return -1;}
			if  (diff1>diff2){return 1;}
			return 0;
		});
	}
	else
	{
		rows.sort(function(row1,row2){
			var diff1=Date.parse($(row1).find('td').eq(1).text());
			var diff2=Date.parse($(row2).find('td').eq(1).text());
			if  (diff1<diff2){return -1;}
			if  (diff1>diff2){return 1;}
			return 0;
		});
	}
	$(rows).each(function(){
		$(this).appendTo(`#${table} tbody`);
	});
}
