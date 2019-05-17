$(function(){
  $("#checklist_rows").on("click", '.header_toggle_btn', function(e){
    e.preventDefault();
    if($(this).hasClass("btn-default")){
      $(this).closest('td').find('#is_header').val(true);
      $(this).removeClass("btn-default").addClass("btn-success");
    }else{
      $(this).closest('td').find('#is_header').val(false);
      $(this).removeClass("btn-success").addClass("btn-default");
    }
  });

  $("#checklist_rows").on("click", '.remove_btn', function(e){
    e.preventDefault();
    $(this).closest("td").find("#delete_row").val(true);
    $(this).closest(".to_delete").hide();
  });
});