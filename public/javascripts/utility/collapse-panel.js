$(document).on('click', '.click-heading', function(e){
    var $this = $(this);
	if(!$this.hasClass('collapsed')) {
		$this.closest('.panel').find('.panel-body').slideUp();
		$this.addClass('collapsed');
		$this.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
	} else {
		$general=$this.closest('.panel-body')
		$general.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
		$this.removeClass('collapsed');
		$this.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
		$this.closest('.panel').find('.panel-body').slideDown();
	}
});