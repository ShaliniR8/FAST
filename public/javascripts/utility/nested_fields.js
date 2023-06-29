//function to add nested attributes
function add_fields(link, association, content, target) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  var insertposition = "#" + target;
  console.log(insertposition);
  $(content.replace(regexp, new_id)).appendTo($(link).closest(".panel-body").find(insertposition));
}

function update_row_order_checklist_row(table_class){
  $(".row_order_new_checklist_row").each(function(){
    var currIndex = $(`#${table_class} tbody tr`).index($(this).closest('tr'));
    $(this).val(currIndex);
  })
  $(".row_order_new_checklist_row").removeClass("row_order_new_checklist_row")
}
