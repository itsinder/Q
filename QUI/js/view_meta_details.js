$(document).ready(function () {
function getSearchParams(k){
 var p={};
 location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi,function(s,k,v){p[k]=v})
 return k?p[k]:p;
}

 	$.ajax({
		type: "POST",
    url: "meta_data.txt",
    dataType: 'json',
    success: function(data){
    // For Debugiing: 
   //console.log(data);
var vec = getSearchParams("v");
//var obj = getValues(data, vec);
//console.log(vec);
  // Make customised table
  $.makeTable = function (jsonData) {
  var table = $('<table id="myTable" class="table table-striped table-condensed" style="word-wrap: break-word"><thead> <tr><th>key</th><th>value</th> </tr></thead>');

			for (var k in jsonData) 
			//tblHeader += "<th>" + k[0] + "</th>";
			if (k == vec) {
      console.log("key : " + k + " - value : " + jsonData[k]);
			console.log(jsonData[k]);
			for (var key in jsonData[k])
			$.each(jsonData[k], function (index, value) {
						if (index == 'base') {
    	var TableRow = "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Field Type</td>";
	TableRow +=  "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>" + value['field_type'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Num in Chunk</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['num_in_chunk'] + "</td>"; 
	TableRow += "</tr>";
  TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Chunk Size</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['chunk_size'] + "</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Chunk Num</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['chunk_num'] +"</td>"; 
	TableRow += "</tr>";

  TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>File Size</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['file_size'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Num Elements</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['num_elements'] +"</td>"; 
	TableRow += "</tr>";

  TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Open Mode</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['open_mode'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Field Size</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['field_size'] +"</td>"; 
	TableRow += "</tr>";

  TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>File Name</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['file_name'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Is Persist?</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+value['is_persist'] +"</td>"; 
	TableRow += "</tr>";

  TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Is eov?</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['is_eov'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Is nascent?</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['is_nascent'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Name</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['name'] +"</td>"; 
	TableRow += "</tr>";

	TableRow += "<tr>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>Is memo?</td>";
	TableRow += "<td style='word-wrap: break-word;min-width: 160px;max-width: 160px;'>"+ value['is_memo'] +"</td>"; 
	TableRow += "</tr>";
}
   	$(table).append(TableRow);
  	});
}
  	return ($(table));
	};
	var jsonData = eval(data);
	var table = $.makeTable(jsonData);
	$(table).appendTo("#show-data");
	}
	});
});
