$(document).ready(
  function(){
    $(".invite_btn").on("click",function(){
      if ($(this).text() == "Invite"){
        $(this).text("Invited");
        $(this).removeClass("btn-info").addClass("btn-success");
      }else{
        $(this).text("Invite");
        $(this).removeClass("btn-success").addClass("btn-info");
      }
    });

    var dt = $('#participants').DataTable({
      "aLengthMenu": [[5, 10, 15, -1], [5, 10, 15, "All"]],
      "iDisplayLength": 5
    });
    $('form').on('submit',function(){
      var count = 0;
      var form = $(this);
      dt.rows().nodes().to$().each(function(){
        if ($(this).find(".invite_btn").text() == "Invited"){
          form.append('<input type="hidden" name=sms_meeting[invitations_attributes]['+count+ '][users_id] value='+$(this).attr("user")+'>');
          count++;
        }
      });
      return true;
    });
  }
);
