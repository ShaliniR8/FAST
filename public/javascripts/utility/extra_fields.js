$(document).ready(function(){

  var submit_btn;

  $(":submit").click(function(){
    submit_btn = $(this).val();
  });

  $("form").on('submit',function(event){
    if(submit_btn == "Save for Later"){
      // buttons.removeAttr('data-disable-with');
    }else{

      $(this).find('.required_field').each(function(){
        if($(this).closest("div.nested_field").css("display") == "none"){
          $(this).switchClass("required_field", "required_field_hidden")
        }
      });

      $(this).find('.required_field_hidden').each(function(){
        if($(this).closest("div.nested_field").css("display") != "none"){
          $(this).switchClass("required_field_hidden", "required_field")
        }
      });

      var error = false;
      var result = true;

      $(".required_field").css('border-color', '');
      $(this).find('.required_field').each(function(){
        if ($(this).val() == ""){
          error = true;
          result = false;
          $(this).css('border-color', 'red');
          event.preventDefault();
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



