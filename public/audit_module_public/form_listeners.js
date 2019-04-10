$(document).on("change", "[data-select-with-other]", function() {
	if(this.options[this.selectedIndex].value == "Other") {
		$("#" + this.id.substring(5)).show();
	}
	else {
		$("#" + this.id.substring(5)).hide();
	}
});