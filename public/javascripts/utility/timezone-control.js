$(document).ready(function(){
	$(".tc").on('click',function(){
		timezone=$(this).closest(".input-group").find(".tz");
		if (timezone.hasClass("atz"))
		{
			ustimezone=["Hawaii", "Alaska", "Pacific Time (US & Canada)", "Arizona", "Mountain Time (US & Canada)", "Central Time (US & Canada)", "Eastern Time (US & Canada)", "Indiana (East)"]
			timezone.removeClass("atz");
			timezone.addClass("ustz");
			timezone.val('');
			timezone.find('option').each(function(){
				opt=$(this);
				if (ustimezone.indexOf(opt.text())==-1)
				{
					opt.hide();
					opt.wrap('<span>'); // hide for safari
				}
			});
			$(this).text("US");
		}
		else
		{
			timezone.removeClass("ustz");
			timezone.addClass("atz");
			$(this).text("All");
			// timezone.find('option').show();

			// unhide for safari
			timezone.find('option').each(function(){
				opt = $(this);
				if (ustimezone.indexOf(opt.text())==-1)
				{
					opt.show();
					opt.unwrap(); // unhide for safari
				}
			});
			timezone.find('option:first').attr('selected', 'selected');
		}
	});
    //$('.tc').trigger('click');

});
