$(document).on('click', '.click-heading', function(e){
    var $this = $(this);
	if(!$this.hasClass('collapsed')) {
		$this.closest('.panel').find('.panel-body').eq(0).slideUp();
		$this.addClass('collapsed');
		$this.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
	} else {
		$general=$this.closest('.panel-body');
		$this.removeClass('collapsed');
		$this.find('i').eq(0).removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
		$this.closest('.panel').find('.panel-body').eq(0).slideDown();
	}
});
$(document).ready(function(){
	$(".expandall").on("click",function(){
		if ($(this).hasClass('expanded')){
			$(".click-heading").each(function(){
				$this = $(this);
				$this.closest('.panel').find('.panel-body').slideUp();
				$this.addClass('collapsed');
				$this.find('i').removeClass('glyphicon-chevron-up').addClass('glyphicon-chevron-down');
			});
			$(this).removeClass('expanded');
			$(this).text("Expand All");
		}
		else{
			$(".click-heading").each(function(){
				$this = $(this);
				$general=$this.closest('.panel-body')
				$this.removeClass('collapsed');
				$this.find('i').removeClass('glyphicon-chevron-down').addClass('glyphicon-chevron-up');
				$general.closest('.panel').find('.panel-body').slideDown();	
			});
			$(this).addClass('expanded');
			$(this).text("Collapse All");
		}
    });
});
 
