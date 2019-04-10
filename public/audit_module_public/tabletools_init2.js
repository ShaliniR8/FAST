$(document).ready(function() {
		var header=[];
		var table=$('#tabletools').DataTable( {
			"order": [[ 6,"asc"],[7,"asc"]],
			// "bScrollAutoCss": false,
			"oLanguage": {
			    "sSearch": "",
			    "sLengthMenu": "<span>_MENU_</span>",
			    "sEmptyTable": "No audits found.",

			},
			"sDom": "T<'row'<'col-md-6 col-xs-12 'l><'col-md-6 col-xs-12'f>r>t<'row'<'col-md-4 col-xs-12'i><'col-md-8 col-xs-12'p>>",
			tableTools: {
				"sSwfPath": "http://cdn.datatables.net/tabletools/2.2.2/swf/copy_csv_xls_pdf.swf",
				"aButtons": [ 
			      "copy",
			      "xls",
			      "pdf",
			      "print",
			      "select_all", 
			      "select_none" 
			  ]
			},
			"lengthMenu": [[10,25,50,100,-1], [10,25,50,100,"All"]]
		});
		function collapseall(){
			table.rows().nodes().to$().each(function () {
				function haspair(head,ob){		
					for ( var i=0;i<head.length;i++){
						if (head[i][0]==ob[0] && head[i][1]==ob[1]){
							return true;
						}
					}
					return false;
				} 
			    var city= $('td', this).eq(6).html();
			    var code= $('td', this).eq(7).html();
			    var obj=[city,code]
			    if (haspair(header,obj)){
			    	$(this).hide();
			    }
			    else{
			    	header.push(obj);
			    }
			});
		}
		removeextraicon();
		collapseall();
		expand();
		
		$("#reset").click( function(){
			header=[];
			table.order([[ 6,"asc"],[7,"asc"]]).draw();
			collapseall();
			table.rows().nodes().to$().each(function () {
				$('td', this).eq(0).html("<a type='button' class='btn btn-warning btn-md'><center><span class='glyphicon glyphicon-chevron-down'></span></center></a>");
				$('td', this).eq(0).show();
			});
			removeextraicon();
			expand();
			$('#tabletools > thead > tr').each(
				function(){
					$('th', this).eq(0).show();
				}
			);
			table.page.len(10).draw();	
		});

		$("thead th").click(function() {
			table.rows().nodes().to$().each(function () {
					$('.expand',this).hide();
				}
			);
			$('#tabletools > thead > tr').each(
				function(){
					$('.expand').hide();
				}
			);
			expandall();
		} );
		/*$('#tabletools').on( 'order.dt', function () {
			table.rows().nodes().to$().each(function () {
					$('.expand',this).hide();
				}
			);
			$('#tabletools > thead > tr').each(
				function(){
					$('.expand').hide();
				}
			);
			expandall();
		});*/
		function expandall(){
			table.rows().nodes().to$().each(function () {
			    $(this).show();
			});
		}		
		function expand(){
			table.rows().nodes().to$().each(function () {
				$('.btn-warning',this).click(function(){
					var $row = $(this). closest("tr");
					var $cell= $(this). closest("td");
					var city= $('td', $row).eq(6).html();
				    var code= $('td', $row).eq(7).html();
				    rowcount=0;
				    table.rows().nodes().to$().each(function () {
				    	
				    	var audit= $('td', this).eq(6).html();
				    	var share= $('td', this).eq(7).html();
				    	if (audit==city && code==share){
				    		rowcount++;
				    		$(this).show(100);
				    		$('td', this).eq(0).html("");
				    	}

					});
				    table.page.len(-1).draw();			
					$cell.html("<a type='button' class='btn btn-warning btn-md'><center><span class='glyphicon glyphicon-chevron-up'></span></center></a>");
					collapse();
				});
			});
		}
		function collapse(){
			table.rows().nodes().to$().each(function () {
				$('.btn-warning',this).click(function(){
					var $row = $(this). closest("tr");
					var $cell= $(this). closest("td");
					var city= $('td', $row).eq(6).html();
				    var code= $('td', $row).eq(7).html();
				    rowcount=0;
				   	table.rows().nodes().to$().each(function () {

				    	var audit= $('td', this).eq(6).html();
				    	var share= $('td', this).eq(7).html();
				    	if (audit==city && code==share){
				    		rowcount++;
				    		$(this).hide(200);
				    		$('td', this).eq(0).html("");
				    	}
					});
					$row.show(400);
				    $cell.html("<a type='button' class='btn btn-warning btn-md'><center><span class='glyphicon glyphicon-chevron-down'></span></center></a>");
					expand();
				});
			});
		}
		function removeextraicon()
		{
			table.rows().nodes().to$().each(function () {
			    var city= $('td', this).eq(6).html();
			    var code= $('td', this).eq(7).html();
			    var count=0;
			    table.rows().nodes().to$().each(function () {
			    	var current_city= $('td', this).eq(6).html();
			    	var current_code= $('td', this).eq(7).html();
			    	if (current_city==city && current_code==code){
			    		count++;
			    	}
			    });
			    if (count<=1){
			    	$('td', this).eq(0).html("");
			    } 
			});
		}
		$("input",$("#tabletools_filter")).on('input',
			function(){
				table.rows().nodes().to$().each(function () {
					$(this).show();
					$('td', this).eq(0).hide();
				});
				$('#tabletools > thead > tr').each(function (){
					$('th', this).eq(0).hide();
				});
			}
		);
});