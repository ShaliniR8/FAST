// GISPainter helper class draws various objects on map
var GISPainter = new function () {
  this.init = function (map) {
    GISPainter.map = map;
    GISPainter.activeShape = new GISShape({});
    GISPainter.activeMarker = new GISMarker({});
    GISPainter.activePolygon = new google.maps.Polygon({});
    GISPainter.activePolyline = new google.maps.Polyline({});
    GISPainter.activeAnimatedline = new google.maps.Polyline({});
  }

  this.reset = function () {
    GISPainter.erase(GISPainter.activeShape.display);
    GISPainter.erase(GISPainter.activeMarker.display);
    GISPainter.erase(GISPainter.activePolygon);
    GISPainter.erase(GISPainter.activePolyline);
    GISPainter.erase(GISPainter.activeAnimatedline);
  }

  // Erase elements from map (accepts any number of elements)
  this.erase = function (elements) {
    if (!elements)
      return;

    if (Object.prototype.toString.call(elements) !== "[object Array]")
      elements = [elements];

    for (var i in elements)
      elements[i].setMap(null);
  }

  this.drawMarker = function (marker) {
    var options = {
      position:  marker.position,
      icon:      marker.icon,
      draggable: marker.draggable,
      fillColor: 'yellow',
      map:       GISPainter.map
    };

    instance = marker.display || new google.maps.Marker();
    instance.setOptions(options);

    return instance;
  }

  this.drawPolygon = function (polygon) {
    var options = {
      paths: polygon.paths,
      draggable: polygon.editable,
      editable: polygon.editable,
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillOpacity: 0.4,
      strokeColor: 'yellow',
      fillColor: 'yellow',
      map: GISPainter.map
    };

    instance = polygon.display || new google.maps.Polygon();
    instance.setOptions(options);
    return instance;
  }

  // this.drawPolyline = function(path, instance, clickable) {
  this.drawPolyline = function (polyline) {
    var options = {
      path: polyline.paths,
      geodesic: true,
      clickable: polyline.clickable !== undefined ? polyline.clickable : true,
      strokeOpacity: 0.8,
      strokeWeight: 4,
      strokeColor: 'yellow',
      map: GISPainter.map
    };

    instance = polyline.display || new google.maps.Polyline();
    instance.setOptions(options);
    return instance;
  }
}
