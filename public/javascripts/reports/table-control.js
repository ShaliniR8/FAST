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
				row.appendTo("#candidates tbody");
				sorttr();
			}else{
				$(this).removeClass("btn-warning").addClass("btn-danger");
				row=$(this).closest("tr").detach();
				$(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-remove");
				row.appendTo("#included tbody");
				sorttr();
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
			$("#candidates tbody tr").each(function(){
        if(typeof($(this).attr("record")) !== "undefined"){
				  form.append('<input type="hidden" name=dettach['+count+ '] value='+$(this).attr("record")+'>');
				  count++;
        }
			});
			return true;
		});
	}
);
function sorttr()
{

	var rows=$("#candidates tbody tr").get();
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
		$(this).appendTo("#candidates tbody");
	});
}
