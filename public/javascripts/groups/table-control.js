$(document).ready(
	function(){
		$(".action-btn").on("click",function(){
			var action_table=$(this).closest("table");
			if (action_table.attr('id')=="included")
			{
				$(this).removeClass("btn-danger").addClass("btn-warning");
				row=$(this).closest("tr").detach();
				$(this).find("span").removeClass("glyphicon-remove").addClass("glyphicon-plus");
				row.appendTo("#candidates tbody");
			}
			else
			{
				$(this).removeClass("btn-warning").addClass("btn-danger");
				row=$(this).closest("tr").detach();
				$(this).find("span").removeClass("glyphicon-plus").addClass("glyphicon-remove");
				row.appendTo("#included tbody");
			}
		});
		$('form').on('submit',function(){
			var count=0;
			var form=$(this);
			$("#included tbody tr").each(function(){
				console.log(count+"="+$(this).attr("record"));
				form.append('<input type="hidden" name=records['+count+ '] value='+$(this).attr("record")+'>');
				count++;
			});
			$("#candidates tbody tr").each(function(){
				console.log(count+"="+$(this).attr("record"));
				form.append('<input type="hidden" name=dettach['+count+ '] value='+$(this).attr("record")+'>');
				count++;
			});
			return true;
		});
	}
);
