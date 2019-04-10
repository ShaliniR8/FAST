$(document).ready(function(){
	$("#inv_btn").on('click',function(){
		if ($(this).hasClass("drop"))
		{
			console.log("keep old selection");
			$("#send_to_group").hide();
			$(this).text("Select Group");
			$(this).removeClass("drop");
			$("#invitee_table").show();
		}
		else
		{
			$(this).addClass("drop");
			$("#invitee_table").hide();
			$(this).text("Select Invitees");
			$("#send_to_group").show();
		}
	});
	$(".select_btn").on("click",function(){
		if ($(this).text()=="Select")
		{
			$(this).text("Selected");
			$(this).removeClass("btn-info").addClass("btn-success");
		}
		else
		{
			$(this).text("Select");
			$(this).removeClass("btn-success").addClass("btn-info");
		}
	});
	var dt=$('#users').DataTable({
			"aLengthMenu": [[5, 10, 15, -1], [5, 10, 15, "All"]],
			"iDisplayLength": 5
	});
	$('form').on('submit',function(){
		var count=0;
		var form=$(this);
		dt.rows().nodes().to$().each(function(){
			//console.log(count+"="+$(this).attr("user"));
		if ($(this).find(".select_btn").text()=="Selected")
			{
				form.append('<input type="hidden" name=message_to['+count+ '] value='+$(this).attr("user")+'>');
				count++;
			}
		});
		return true;
	});
});