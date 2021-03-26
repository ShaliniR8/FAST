// Marker class holds a marker'data and visual
function GISMarker(params) {
  this.id           = params.id || '';
  this.type         = params.type || 'marker-new';
  this.title        = params.title || '';
  this.layerId      = params.layerId || '';
  this.position     = params.position || null;
  this.icon         = params.icon || null;
  this.connected    = params.connected || false;
  this.preloaded    = params.preloaded || false;
  this.connections  = params.connections || [];
  this.display      = params.display || null;
  this.archived     = params.archived || false;
  this.draggable    = params.draggable || false;
}

GISMarker.prototype.listen = function(event, callback) {
  google.maps.event.clearListeners(this.display, event);
  this.display.addListener(event, callback);
}

GISMarker.prototype.getPosition = function() {
  return this.position;
}

GISMarker.prototype.draw = function(position) {
  this.position = position || this.position;
  this.display = GISPainter.drawMarker(this);
}

GISMarker.prototype.erase = function() {
  GISPainter.erase(this.display);
}

GISMarker.prototype.setColor = function () {
  if (this.archived) {
    var color = 'black';
  } else if (this.connection) {
    var color = 'blue';
  } else {
    var color = 'yellow'
  }
  var icon = this.display.getIcon();
  icon.fillColor = color;
  this.display.setIcon(icon);
}

GISMarker.prototype.setDraggable = function (draggable) {
  this.draggable = draggable
  this.display.setDraggable(draggable)

  if (draggable) {
    var this_ = this;
    this.listen('dragend', function () {
      this_.updatePosition(this_)
    })
  }
}

GISMarker.prototype.updatePosition = function (marker) {
  $.ajax({
    type: 'PUT',
    url: '/gis/markers/' + marker.id,
    data: {
      gis_marker: {
        lat: marker.display.getPosition().lat(),
        lng: marker.display.getPosition().lng()
      }
    }
  })
}
