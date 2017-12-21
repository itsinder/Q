$(document).ready(function () {
 	$.ajax({
		type: "POST",
    url: "meta_data.txt",
    dataType: 'json',
    success: function(data){
    // For Debugiing: console.log(data);

  // Make customised table
  $.makeTable = function (jsonData) {
  var table = $('<table id="MetaData" class="table table-striped table-condensed" style="word-wrap: break-word"><thead> <tr><th>vector</  th><th>field_type</th><th>chunk size</th> </tr></thead>');
		for (var k in jsonData[0]) 
			tblHeader += "<th>" + k[0] + "</th>";
			$.each(jsonData, function (index, value) {
    	var TableRow = "<tr>";
			TableRow += "<td><a href='view_meta_details.html?v=" + index + "'>" + index + "</td>";
			TableRow += "<td>" + value['base']['field_type'] + "</td>";
			TableRow += "<td>" + value['base']['chunk_size'] + "</td>";
			TableRow += "</tr>";
    	$(table).append(TableRow);
  	});
  	return ($(table));
	};
	var jsonData = eval(data);
	var table = $.makeTable(jsonData);
	$(table).appendTo("#show-data");
	}
	});
});
