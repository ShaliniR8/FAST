$(document).ready(function(){
  let datetime_format = 'Y-m-d H:i'
  let date_format     = 'Y-m-d'

  // Update date_format
  try {
    date_format = $('.field-date')[0].dataset["format"]
    if (date_format == undefined) {
      date_format = 'Y-m-d'
    }
  } catch(error) {
    // console.log(error)
    date_format = 'Y-m-d'
  }

  // Update datetime_format
  try {
    datetime_format = $('.field-datetime')[0].dataset["format"]
    if (datetime_format == undefined) {
      datetime_format = 'Y-m-d H:i'
    }
  } catch(error) {
    // console.log(error)
    datetime_format = 'Y-m-d H:i'
  }

  $('.field-date').flatpickr({
    altInput: true,
    altFormat: date_format,
    dateFormat: 'Y-m-d',
  });

  $('.field-datetime-now').flatpickr({
    dateFormat: 'Y-m-d H:i',
    enableTime: true,
    defaultDate: new Date(),
    time_24hr: true,
  });

  $('.field-datetime').flatpickr({
    altInput: true,
    altFormat: datetime_format,
    enableTime: true,
    dateFormat: 'Y-m-d H:i',
    time_24hr: true,
    allowInput: true,
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
