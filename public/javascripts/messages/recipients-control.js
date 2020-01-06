$(document).ready(function(){

	$(".send_btn").on("click",function(){
		if ($(this).hasClass('btn-transparent')){
			$(this).removeClass('btn-transparent').addClass('btn-danger');
			$(this).next(".cc_btn").removeClass('btn-danger').addClass('btn-transparent');
		}else{
			$(this).removeClass('btn-danger').addClass('btn-transparent');
		}
	});

	$(".cc_btn").on("click",function(){
		if ($(this).hasClass('btn-transparent')){
			$(this).removeClass('btn-transparent').addClass('btn-danger');
			$(this).prev(".send_btn").removeClass('btn-danger').addClass('btn-transparent');
		}else{
			$(this).removeClass('btn-danger').addClass('btn-transparent');
		}
	});


  var recipients_table = $('#recipients').DataTable({
    "iDisplayLength": 5
  });


  $('form').on('submit', function() {
    var send_count = 0
    var cc_count = 0
    var form = $(this)
    recipients_table.rows().nodes().to$().each(function() {
      if ($(this).find('.send_btn').hasClass('btn-danger')){
        form.append("<input type='hidden' name=send_to[" + send_count++ + "] value=" + $(this).attr('user') + ">")
      }

      if ($(this).find('.cc_btn').hasClass('btn-danger')){
        form.append("<input type='hidden' name=cc_to[" + send_count++ + "] value=" + $(this).attr('user') + ">")
      }
    })

    if (send_count + cc_count === 0) {
      event.preventDefault()
      swal({
        title:  'Message has no recipient.',
        type:   'error',
      })
      return false
    }
    return true
  })
})



