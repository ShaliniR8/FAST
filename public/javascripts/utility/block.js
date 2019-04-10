function add_blocks(base_area,namespace,insert_space){
  var content="<%=escape_javascript(render('block'))%>"
  var uid=new Date().getTime();
  var name_space=namespace+"["+uid+"]";
  var regexp=new RegExp("name_space","g");
  var regexp2=new RegExp("insert_space","g");
  var insertposition=$("#to_insert_"+insert_space);
  var insertspace=insert_space+"_"+uid;
  $(content.replace(regexp, name_space).replace(regexp2,insertspace)).appendTo(insertposition);
  $(base_area).closest(".value_area").remove
}