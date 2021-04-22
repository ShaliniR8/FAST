$(document).ready(function(){

  var submit_btn;

  $(":submit").click(function(){
    submit_btn = $(this).val();
  });

  $("form").on('submit',function(event){
    if(submit_btn == "Save for Later"){
      // buttons.removeAttr('data-disable-with');
    }else {
      if (!$('div').hasClass('ignore_validation')) {
        $(this).find('.required_field').each(function(){
          if($(this).closest("div.nested_field_area").css("display") == "none"){
            $(this).switchClass("required_field", "required_field_hidden")
          }
        });

        $(this).find('.required_field_hidden').each(function(){
          if($(this).closest("div.nested_field_area").css("display") != "none"){
            $(this).switchClass("required_field_hidden", "required_field")
          }
        });

        var error = false;
        var result = true;
        var count;

        $(".required_field").css('border-color', '');
        $(this).find('.required_field').each(function(){
          var cboxes = $(this).find('.checkbox_mul').get();
          var radios = $(this).find('.radio_req').get();
          if($(this).closest("div.nested_field_area").css("display") != "none"){
            if (radios == null || radios.length == 0) {
              if (cboxes == null || cboxes.length == 0) {
                if ($(this).val() == ""){
                  error = true;
                  result = false;
                  $(this).css('border-color', 'red');
                  event.preventDefault();
                }
              } else {
                var lim = $(this).attr('name');
                count = 0;
                $(this).find('.checkbox_mul').each(function(){
                  if ($(this).prop('checked')) {
                    count ++;
                  }
                });
                if (count < lim){
                  error = true;
                  result = false;
                }
              }
            } else {
              count = 0;
              $(this).find('.radio_req').each(function() {
                  if ($(this).prop('checked')) {
                    count ++;
                  }
              });
              if (count < 1) {
                error = true;
                result = false;
              }
            }
          }
        });
        if (error){
          swal({
            title: "Error",
            text: "Please fill in all required fields.",
            type: "error",
            customClass: 'custom-swal',
          }).catch(swal.noop);
          return result;
        } else {
          if($(".map_button")[0]) {
            remove_placeholder_point_html();
          }
        }
      }
      if (error){
        swal({
          title: "Error",
          text: "Please fill in all required fields.",
          type: "error",
          customClass: 'custom-swal',
        }).catch(swal.noop);
        return result;
      } else {
        if($(".map_button")[0]) {
          remove_placeholder_point_html();
        }
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



