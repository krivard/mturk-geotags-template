//var predictions_map = {};
//var mymap;
//var locIndex;
//var opacityFlag = 1;

var geotags = {
    zoomLevels: function() {
	var a=5; var b=10; var c=11; var d=13; var e=15;
	return {
	 country: a,
	 mountain: b,
	 river: b+2,
	 stateorprovince: b,
	 city: c,
	 lake: e,
	 stadiumoreventvenue: d,
	 university: d,
	 building: e,
	 hotel: e+1,
	 monument: e-1,
	 museum: e,
	 park: e,
	 radiostation: e,
	 restaurant: e,
	 sportsteam: e,
	 street: e,
	 televisionstation: e
	};}()
};
//var filename = "";
var key = "AIzaSyBA-phjQc5udwGuXqzlC1C6NOeDW3kaJvs"; // kmr
//var key = "AIzaSyD3hN53q-mMr3FodMTZ6Kzv8KHZvpOqdHE"; // dmv

function loadScript() {
	opacityFlag = 1;
	var script = document.createElement("script");
	script.type = "text/javascript";
	script.src = "http://maps.googleapis.com/maps/api/js?key="+key+"&sensor=false&callback=loadMap";
	document.body.appendChild(script);
}

function loadMap() {
    var cat = geotags.data[0].title.split(":")[0];
    var typeid = google.maps.MapTypeId.ROADMAP;
    if (cat === "mountain" || cat === "river" ) { typeid = google.maps.MapTypeId.TERRAIN; }
	var mapOptions = {
			zoom: 4,
			center: new google.maps.LatLng(37.09024, -95.712891),
			mapTypeId: typeid
	};

	var map = new google.maps.Map(document.getElementById("map"),
			mapOptions);
	
	console.log("Map loaded.");//console.log(map);
	geotags.map = map;
	
	geotags.infoWindow = new google.maps.InfoWindow({
		pixelOffset:new google.maps.Size(-1,36)
	});
	google.maps.event.addListener(geotags.map, 'click', function() {
		geotags.infoWindow.close();
	});
	
	//console.log(geotags.data[0]);
	addMarker(geotags.data[0]);

	var bounds = new google.maps.LatLngBounds();
	//var clusterer = new MarkerClusterer(map,[],{gridSize:50});
	//for (var i=0;i<geotags.data.length;i++) { 
	//    var marker = addMarker(geotags.data[i]);//,geotags.icons[i],geotags.shadows[i]);
		//clusterer.addMarker(marker);
	bounds.extend(geotags.data[0].marker.getPosition()); 
	//}
	//map.setZoom(map.getBoundsZoomLevel(bounds));
	//map.setCenter(bounds.getCenter());
	//for (var l=0;l<geotags.loaders.length;l++) { geotags.loaders[l](bounds); }
	var newzoom = geotags.zoomLevels[cat];
	if (!bounds.isEmpty()) { 
		map.fitBounds(bounds); 
		google.maps.event.addListenerOnce(map,"idle",function() { map.setZoom(newzoom); });
						  //{ if (map.getZoom() > 9) map.setZoom(9); }); 
	}
	console.log("Zoom:"+map.getZoom());
}

function addMarker(data) { //,icon,shadow) {
	var marker = new google.maps.Marker({
		map: geotags.map,
		position: new google.maps.LatLng(data.lat, data.lng),
		draggable: false,
		title: data.title,
		//icon: icon,
		//shadow: shadow,
		zIndex: data.zIndex
	});
	google.maps.event.addListener(marker, 'click', function() {
		zoomOnLocation(data);
	});
	data.marker = marker;
	return marker;
}

function zoomOnLocation(data){
	var zoomLevel;
	

	// open info window
	geotags.infoWindow.setContent(
			'<table id="geotags-info">'+
			'<tr class="heading"><th colspan="2" class="instance">'+ data.title +'</th></tr>' +
			'<tr><td class="label">Latitude</td><td class="label">Longitude</td></tr>'+
			'<tr><td> '+data.lat+'</td><td> '+data.lng+'</td></tr>'+
			'</table>');
	geotags.infoWindow.open(geotags.map, data.marker);
}

/*
function loadPredictionData(filename){
	predictions_map = {};

	if(filename == ""){
		filename = "prediction.txt";
	}

	var txtFile = new XMLHttpRequest();
	//txtFile.open("GET", "http://www.cs.cmu.edu/~dmovshov/GeoTags/prediction.txt", false);
	txtFile.open("GET", "http://www.cs.cmu.edu/~dmovshov/GeoTags/"+filename, false);
	txtFile.onreadystatechange = function() {
		if (txtFile.readyState === 4) {  // Makes sure the document is ready to parse.
			if (txtFile.status === 200) {  // Makes sure it's found the file.
				var allText = txtFile.responseText; 
				var lines = txtFile.responseText.split("\n"); // Will separate each line into an array

				for (var i=0; i < lines.length-1; i++) {
					var line = lines[i];
					if(i == 0){
						document.getElementById("location").innerHTML = line;
						continue;
					}

					var parts = line.split("\t");
					predictions_map[i] = {
							name: parts[0],
							lat: parts[1],
							lng: parts[2],

							distance: parseFloat(parts[3])*1000,
							prior: parts[4],
							alignProb: parts[5],
							adjustedPrior: parts[6],
							combined: parts[7],
							relative: parts[8],

							cleanName: parts[9]
					}
				}
			} //status
		} //ready
		//txtFile.close();
	} //state change
	txtFile.send(null);
}

function toggleOpacity(){
	if(opacityFlag == 1){
		opacityFlag = 0;
	}
	else{
		opacityFlag = 1;
	}

	displayPrediction();
}

function loadFile(){
	var filename = document.getElementById("query").value;
	loadScript();
}

function loadMe(file){
	var filename = file;
	loadScript();
}

function addCellToRow(oRow, cellType, text){
	var oCell = document.createElement(cellType);
	oCell.innerHTML = text;
	oRow.appendChild(oCell);
}


// not in use - kmr june 2012
function displayPrediction(filename) {
	var mapOptions = {
			zoom: 4,
			center: new google.maps.LatLng(37.09024, -95.712891),
			mapTypeId: google.maps.MapTypeId.TERRAIN
	};

	mymap = new google.maps.Map(document.getElementById("map_canvas"),
			mapOptions);

	loadPredictionData(filename);

	var circleOptions;
	var locationCircle;
	var marker;
	var area;

	infoWindow = new google.maps.InfoWindow;

	google.maps.event.addListener(mymap, 'click', function() {
		infoWindow.close();
	});

	if(document.getElementById("resultsTableContainer").childNodes.length > 0){
		document.getElementById("resultsTableContainer").removeChild(document.getElementById("resultsTableContainer").firstChild);
	}

	var oTable = document.createElement("table");
	var oTHead = document.createElement("thead");
	var oTBody = document.createElement("tbody");
	var oCaption = document.createElement("caption");
	var oRow;
	document.getElementById("demo").innerHTML = "";

	if(Object.keys(predictions_map).length == 0){
		document.getElementById("demo").innerHTML = "Oops, can't find this place :( <br>";
	}
	else{
		document.getElementById("demo").innerHTML = "";
		oCaption.innerHTML = "Predicted locations"
			oTable.appendChild(oTHead);
		oTable.appendChild(oTBody);
		oTable.appendChild(oCaption);
		oTable.cellPadding = 5;
		oTable.border = 1;
		oTable.className = "results";

		oRow = document.createElement("TR");
		oTHead.appendChild(oRow);
		addCellToRow(oRow, "TH", "#");
		addCellToRow(oRow, "TH", "Name");
		addCellToRow(oRow, "TH", "Lat");
		addCellToRow(oRow, "TH", "Lng");
		addCellToRow(oRow, "TH", "Prior");
		addCellToRow(oRow, "TH", "Adj_P");
		addCellToRow(oRow, "TH", "Combined");
		addCellToRow(oRow, "TH", "Relative");
		addCellToRow(oRow, "TH", "Distance");
		addCellToRow(oRow, "TH", "p(Align)");
		addCellToRow(oRow, "TH", "Action");

	}

	var keyByProb = Object.keys(predictions_map);
	keyByProb.sort(function(a, b) {return predictions_map[b].combined - predictions_map[a].combined});
	//keyByProb.sort(function(a, b) {return predictions_map[b].relative - predictions_map[a].relative});


	for (var l=0;l<keyByProb.length;l++){
		index = keyByProb[l];

		document.getElementById("demo").innerHTML = "<a href=\"http://dbpedia.org/resource/"+predictions_map[index].name+"> link </a>";//+predictions_map[index].name"\"> "+predictions_map[index].name+" </a>";

		oRow = document.createElement("TR");
		oTBody.appendChild(oRow);
		addCellToRow(oRow, "TD", l);
		addCellToRow(oRow, "TD", "<a href=http://dbpedia.org/resource/"+predictions_map[index].name+"> \""+predictions_map[index].cleanName+"\" </a>");
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].lat).toFixed(2));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].lng).toFixed(2));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].prior).toFixed(2));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].adjustedPrior).toFixed(2));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].combined).toFixed(2));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].relative).toFixed(4));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].distance).toFixed(2));
		addCellToRow(oRow, "TD", parseFloat(predictions_map[index].alignProb));				
		addCellToRow(oRow, "TD", "<a href=\"javascript: zoomOnLocation("+index+")\"> Zoom In </a>");

		predictions_map[index].rank = l;

		//area = Math.PI*Math.pow(pred_dist,2);

		var currOpacity = Math.min(predictions_map[index].adjustedPrior, .7);
		if(opacityFlag == 0){
			currOpacity = 0;
		}

		circleOptions = {
				strokeColor: "#FF0000",
				strokeOpacity: 0.8,
				strokeWeight: 2,
				fillColor: "#FF0000",
				//fillOpacity: Math.min(predictions_map[index].combined, .7),
				fillOpacity: currOpacity,
				map: mymap,
				center: new google.maps.LatLng(predictions_map[index].lat, predictions_map[index].lng),
				radius: parseFloat(predictions_map[index].distance)
		};
		locationCircle = new google.maps.Circle(circleOptions);

		marker = new google.maps.Marker({
			map: mymap,
			position: new google.maps.LatLng(predictions_map[index].lat, predictions_map[index].lng),
			draggable: false,
			//title: 'Click to zoom',
			title: index,
//			icon: index
			zIndex: keyByProb.length-l
		});
		google.maps.event.addListener(marker, 'click', function() {
			zoomOnLocation(this.getTitle());
		});
		predictions_map[index].marker = marker;
	}
	if(keyByProb.length > 0){
		zoomOnLocation(keyByProb[0]);
	}

	document.getElementById("resultsTableContainer").appendChild(oTable);
}

function zoomOut(){
	var mapOptions = {
			zoom: 4,
	};
	mymap.setOptions(mapOptions);
	infoWindow.close();
}
*/
//function zoomOnLocation(){
//	zoomOnLocation(locIndex);
//}
