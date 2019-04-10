function removepanel(deletable)
{
	$(deletable).closest('.to_delete').remove();
}
function delete_att(deletable)
{
	var confirmation=confirm("Please confirm that you are deleting this attachment.")
	if (confirmation){
		$(deletable).closest(".to_hide").hide();
		$(deletable).closest(".to_hide").find('.delete_flag').val(1);
	}

}