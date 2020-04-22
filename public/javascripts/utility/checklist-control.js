$(function() {
  $('.checklist_rows').on('click', '.header_toggle_btn', function(event) {
    event.preventDefault()
    if ($(this).hasClass('btn-default')) {
      var hiddenHeaderInput = $(this).closest('td').find('#is_header')
      hiddenHeaderInput.val(true)
      hiddenHeaderInput.change()
      $(this).closest('td').find('#is_header').val(true)
      $(this).closest('tr').addClass('header-row')
      $(this).removeClass('btn-default').addClass('btn-success')
    } else {
      $(this).closest('td').find('#is_header').val(false)
      $(this).closest('tr').removeClass('header-row')
      $(this).removeClass('btn-success').addClass('btn-default')
    }
  })

  $('.checklist_rows').on('click', '.remove_btn', function(event) {
    event.preventDefault()
    var hiddenDeleteInput = $(this).closest('td').find('#delete_row')
    hiddenDeleteInput.val(true)
    hiddenDeleteInput.change()
    $(this).closest('.to_delete').hide()
  })
})
