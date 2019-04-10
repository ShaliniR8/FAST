$(document).ready(function(){
	var options_hash={
		"WEATHER":['Convective Weather','Fog','Heavy Rain','High Temperature','High Winds','Ice/Snow','Lightning','Low Temperature','Other'],
		"AIRPORT":['Ramp Congestion', 'Ramp Conditions (Signage)', 'Ramp Conditions (Airport Layout)','Other'],
		"OPERATIONAL":['Early Departure','Late Arrival','Time / Pressure','Unfamiliar Airport','Other'],
		"COMMUNICATION":['Instructions Misunderstood (From Crew)','Instructions Misunderstood (From Grd Handler)','Instructions Misunderstood (From Headquarters)','Lack of Communication','Language / Accent','Other'],
		"EQUIPMENT":['Improperly Parked','Inoperative','Malfunction','Missing','Unfamiliar Equipment','Other'],
		"MAI CREW FACTORS":['CRM','Distraction','Fatigue','Improper Supervision','Low Experience','Other'],
		"PROCEDURE":['Did not follow procedure','Inadequate procedure','Intentional Non-Compliance','Lack of Procedure','Other'],
		"TRAINING":['Inadequate','None Received','Other']
	}


	// $('.follow').each(function(){
	// 	$(this).hide();
	// 	$(this).closest('.form-group').find('label').hide();
	// });


	$('.master').each(function(){
		// if($(this).val() != ""){
		// 	$('.follow#' + $(this).attr('id')).each(function(){
		// 		$(this).show();
		// 		$(this).closest('.form-group').find('label').show();
		// 	});
		// }else{
			// $('.follow#' + $(this).attr('id')).val('');
			// $('.follow#' + $(this).attr('id')).each(function(){
			// 	// $(this).hide();
			// 	// $(this).closest('.form-group').find('label').hide();				
			// });
		// }
	});

	$('.threat').each(function(){
		if ($(this).val() != ""){
			potential_options = options_hash[$(this).val()];
			$('.subthreat#' + $(this).attr('id')).html(make_options(potential_options));
			var selected_value = $(this).closest("td").next().next().find(".select_value").val();
			$('.subthreat#' + $(this).attr('id')).val(selected_value);
		}else{
			$('.subthreat#' + $(this).attr('id')).html("");
		} 
	});
	$('.err').each(function(){
		if($(this).val() != ""){
			potential_options = options_hash[$(this).val()];
			$('.suberr#' + $(this).attr('id')).html(make_options(potential_options));
			var selected_value = $(this).closest("td").next().next().find(".select_value").val();
			$('.suberr#' + $(this).attr('id')).val(selected_value);
		}else{
			$('.suberr#' + $(this).attr('id')).html("");
		} 
	});

	$('.master').on('change',function(){
		if ($(this).val() != ""){
			$('.follow#' + $(this).attr('id')).each(function(){
				$(this).show();
				$(this).closest('.form-group').find('label').show();				
			})
		}else{
			// $('.follow#' + $(this).attr('id')).val('');
			// $('.follow#' + $(this).attr('id')).each(function(){
				// $(this).hide();
				// $(this).closest('.form-group').find('label').hide();				
			// })
		}
	});

	$('.threat').on('change',function(){
		if ($(this).val() != ""){
			potential_options = options_hash[$(this).val()];
			$('.subthreat#' + $(this).attr('id')).html(make_options(potential_options));
		}else{
			$('.subthreat#' + $(this).attr('id')).html("");
		} 

		// $('.subthreat#' + $(this).attr('id') + " option").each(function(){
		// 	if($(this).text == )
		// });
		// $("select option").each(function(){
		// 	if ($(this).text() == "<%=CauseOption.find(ancestor_ids[@categories.first.level]).name%>")
		// 		$(this).attr("selected", "selected");
		// });
	});
	$('.err').on('change',function(){
		if ($(this).val() != ""){
			potential_options = options_hash[$(this).val()];
			$('.suberr#' + $(this).attr('id')).html(make_options(potential_options));
		}else{
			$('.suberr#' + $(this).attr('id')).html("");
		} 
	});
});


function make_options(options){
	result = "<option></option>";
	length = options.length
	for (i = 0; i < length; i++){
		result += "<option value=\""+options[i]+"\">"+options[i]+"</option>"
	}
	return result;
}

