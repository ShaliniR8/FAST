$(document).ready(function(){

	$('.field-date').flatpickr({
		dateFormat: 'Y-m-d',
	});

	$('.field-datetime-now').flatpickr({
		dateFormat: 'Y-m-d H:i',
		enableTime: true,
		defaultDate: new Date(),
	});

	$('.field-datetime').flatpickr({
		enableTime: true,
		dateFormat: 'Y-m-d H:i',
	});


	$('.field-datetime-autoposition').datetimepicker({
		format: 'YYYY-MM-DD HH:mm',
		ignoreReadonly: true
	});
});

function reset_risk_mitigate(){
	$(".colorcell").html('');
	var sev_val=$("#sev").val();
	var like_val=$("#like").val();
	var likehood="";
	switch (like_val){
		case "A - Improbable":
			likehood = "0";
			break;
		case "B - Unlikely":
			likehood = "1";
			break;
		case "C - Remote":
			likehood = "2";
			break;
		case "D - Probable":
			likehood = "3";
			break;
		case "E - Frequent":
			likehood = "4";
			break;
		default:
			likehood = "";
	}
	switch($("#"+sev_val+"-"+likehood).attr('background')){
		case "#60FF60":
			like_val="Green - Acceptable";
			break;
		case "yellow":
			like_val="Yellow - Acceptable with mitigation";
			break;
		case "orange":
			like_val="Orange - Unacceptable";
			break;
		default:
			like_val="";
	}
	$("#risk").val(like_val);
	$("#"+sev_val+"-"+likehood).html("<span class='glyphicon glyphicon-ok' style='color:red'></span>");
}
function reset_risk(){
	$(".colorcell").html('');
	var sev_val=$("#sev").val();
	var like_val=$("#like").val();
	var likehood="";
	switch (like_val){
		case "A - Improbable":
			likehood="0";
			break;
		case "B - Unlikely":
			likehood="1";
			break;
		case "C - Remote":
			likehood="2";
			break;
		case "D - Probable":
			likehood="3";
			break;
		case "E - Frequent":
			likehood="4";
			break;
		default:
			likehood="";
	}
	switch($("#"+sev_val+"-"+likehood).attr('background')){
		case "#60FF60":
			like_val="Green - Acceptable";
			break;
		case "yellow":
			like_val="Yellow - Acceptable with mitigation";
			break;
		case "orange":
			like_val="Orange - Unacceptable";
			break;
		default:
			like_val="";
	}
	$("#risk").val(like_val);
	$("#"+sev_val+"-"+likehood).html("<span class='glyphicon glyphicon-remove' style='color:red'></span>");
}