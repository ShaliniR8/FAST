$(document).ready(function() {
	var table=$('#tabletools').DataTable( {
		// "bScrollAutoCss": false,
		"oLanguage": {
		    "sSearch": "",
		    "sLengthMenu": "<span>_MENU_</span>",
		    "sEmptyTable": "No audits found.",

		},
		//"iDisplayLength": -1,
	    //"aaSorting": [], // added, temporary code to prevent auto-sorting of first column
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
});