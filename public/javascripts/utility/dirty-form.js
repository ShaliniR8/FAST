$(function() {
  var dirtyFormSelector = 'form.dirty-submit'
  $(dirtyFormSelector).on('blur', ':input:not(:submit)', markAsDirty)
  $(dirtyFormSelector).on('change', ':input:not(:submit)', markAsDirty)
  $(dirtyFormSelector).submit(function(event) {
    event.preventDefault()

    // var excludes = ['utf8', '_method', 'authenticity_token'].reduce(function(excludeString, name) {
    //     return `${excludeString}:not([name='${name}'])`
    // }, '')

    // $(`${dirtyFormSelector} :input:not(.changed)${excludes}`).prop('disabled', true)

    this.submit()
  })
})

function markAsDirty() {
  $(this).addClass('changed')
  
  var changedHiddenInput = $(this).next(':hidden')
  while (changedHiddenInput.length) {
    changedHiddenInput.addClass('changed')
    changedHiddenInput = changedHiddenInput.next(':hidden')
  }

  var nestedData = $(this).attr('name').split(/[[\]]{1,2}/).slice(0, -2)
  while (nestedData.length > 1) {
    parentSelector = `#${nestedData.join('_')}_id`
    $(parentSelector).addClass('changed')

    var changedHiddenInput = $(parentSelector).next(':hidden')
    while (changedHiddenInput.length) {
      changedHiddenInput.addClass('changed')
      changedHiddenInput = changedHiddenInput.next(':hidden')
    }

    nestedData = nestedData.slice(0, -2)
  }
}