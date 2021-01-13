$(function() {
  var dirtyFormSelector = 'form.dirty-submit'
  $(dirtyFormSelector).on('blur', ':input:not(:submit)', markAsDirty)
  $(dirtyFormSelector).on('change', ':input:not(:submit)', markAsDirty)
  $(dirtyFormSelector).submit(function(event) {
    event.preventDefault()

    var excludes = ['utf8', '_method', 'authenticity_token'].reduce(function(excludeString, name) {
        return `${excludeString}:not([name='${name}'])`
    }, '')

    $(`${dirtyFormSelector} :input:not(.changed)${excludes}`).prop('disabled', true)

    this.submit()
  })
})


function markAsDirty() {
  $(this).addClass('changed')
  var changedHiddenInput = $(this).next(':hidden')
  changedHiddenInput.addClass('changed');
  $(this).closest('td').find('.cell-id').addClass('changed');
  $(this).closest('tr').find('.row-id').addClass('changed');

  $(this).closest('.panel-body').find('.category-changeable').addClass('changed');
  $(this).closest('.draggableFieldGroup').find('.form-control').addClass('changed');
}
