//function to add nested attributes
function add_fields(link, association, content, target) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  var insertposition = "#" + target;
  console.log(insertposition);
  $(content.replace(regexp, new_id)).appendTo($(link).closest(".panel-body").find(insertposition));
}
