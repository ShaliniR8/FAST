function initialize() {    
	$('severity_td').on('click',function(){
		if ($(this).data("status")==="checked"){         
			$(this).data("status","");
			$(this).css('background','none');
		}        
		else       
		{
			$(this).data("status","checked");
			$(this).css('background','aqua');
			row_id=$(this).data("row");
			column_id=$(this).data("column");
			$('.severity_td').each(function(){
				if ($(this).data("row")==row_id &&  $(this).data("column")!=column_id)
				{
					(this).data("status","");
					$(this).css('background','none'); 
					}
			});
		}
		calculate_risk();    
	});
	$('.probability_td').on('click',function(){
		if ($(this).data("status")==="checked"){
			$(this).data("status","");
			$(this).css('background','none');        
		}
		else
		{
			$(this).data("status","checked");          
			$(this).css('backgound','aqua');
			row_id=$(this).data("row");
			column_id=$(this).data("column");          
			$('.probability_td').each(function(){
				if ($(this).data("row")==row_id &&  $(this).data("column")!=column_id)
				{
					$(this).data("status","");
					$(this).css('background','none');
				}
			});      
		}
		calculate_risk();
	});
}
function calculate_risk(){    
	var total_severity=0;
	var total_probability=0;
	var severity_checked=0;    
	var probability_checked=0;
	$('.severity_td').each(function(){
		if ($(this).data("status")==="checked"){
			total_severity+=5-2*$(this).data("column");
			severity_checked++;        
		}
	});    
	$('.probability_td').each(function(){
		if ($(this).data("status")==="checked"){
			total_probability+=5-2*$(this).data("column");
			probability_checked++;
		}   
	});
	if (probability_checked>0 && severity_checked>0){        
		set_risk(total_probability*1.0/probability_checked,total_severity*1.0/severity_checked);
	}
	else{
		clear_risk();  
	}
}
function set_risk(row_index,column_index)
{
    if (column_index>4.00){
    	column_index=0; 
    }    
    else if (column_index>2.5)   
    {
    	column_index=1;
    }
    else
    {
    	column_index=2;   
    }
    if (row_index>4.00){        
    	row_index=0;    
    }
    else if (row_index>3.00)
    {
        row_index=1;   
    } 
    else if (row_index>2.00)    
    {
    	row_index=2;    
    }
    else if (row_index>1.00)    
    {
    	row_index=3;   
    }   
    else   
    {
    	row_index=4;
    }    
    clear_risk();
    $('.risk_td').each(function(){
    	if($(this).data("row")==row_index && $(this).data("column")==column_index)
		{          
			$(this).html("<span class='glyphicon glyphicon-remove' style='color:black'></span>");
	    }    
	});
}
function clear_risk()
{   
	$('.risk_td').each(function(){
	    $(this).text("");
	});
}
$(document).ready(function(){
    initialize();   
    load_data();
    $('form').on('submit',function(){
    	var severity_result=[undefined,undefined,undefined,undefined,undefined];
    	var probability_result=[undefined,undefined];
    	$('.severity_td').each(function(){
    		if ($(this).data('status')==="checked")
    		{          
    			severity_result[$(this).data("row")]=$(this).data("column");
    	    }
    	});
    	$('.probability_td').each(function(){
    		if ($(this).data('status')==="checked").
    		{
    			probability_result[$(this).data("row")]=$(this).data("column");
    		}
    	});     
    	for (i=0;i<severity_result.length;i++)
    	{
    		$('form').append("<input name='finding[severity_extra][]' value="+severity_result[i]+"></input>");
    	}
    	for (i=0;i<probability_result.length;i++)
    	{
    		$('form').append("<input name='finding[probability_extra][]' value="+probabilit y_result[i]+"></input>");
    	}
    	return true;
    });
});