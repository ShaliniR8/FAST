// Shape class holds a shape'data and visual
function GISShape(params) {
  this.markers       = [];
  this.paths         = [];
  this.id            = params.id || '';
  this.type          = params.type || 'shape-new';
  this.title         = params.title || '';
  this.layerId       = params.layerId || '';
  this.done          = params.done || false;
  this.line          = params.line || false;
  this.connected     = params.connected || false;
  this.preloaded     = params.preloaded || false;
  this.connections   = params.connections || [];
  this.display       = params.display || null;
  this.archived      = params.archived || false;
  this.editable      = params.editable || false;
  this.dragging      = false;
  this.draggable     = params.draggable || false;
}

GISShape.prototype.pushVertex = function(position) {
  this.paths.push(position);
}

GISShape.prototype.popVertex = function() {
  this.paths.pop();
}

GISShape.prototype.length = function() {
  return this.paths.length;
}

GISShape.prototype.getPosition = function() {
  var bounds = new google.maps.LatLngBounds();
  for (var i = 0; i < this.paths.length; i++)
    bounds.extend(this.paths[i]);
  return bounds.getCenter();
}

GISShape.prototype.setEditable = function (editable) {
  this.editable = editable
  this.draggable = editable
  this.display.setEditable(editable)
  this.display.setDraggable(editable)

  if (editable) {
    var this_ = this;
    this_.listen('dragstart', function () {
      this_.dragging = true;
    });
    this_.listen('dragend', function () {
      this_.updatePath(this_);
      this_.dragging = false;
    });
    this_.listenToPath('insert_at', function () {
      this_.updatePath(this_);
    });
    this_.listenToPath('set_at', function () {
      if (!this_.dragging) {
        this_.updatePath(this_);
      }
    });
  }
}

GISShape.prototype.listen = function(event, callback) {
  google.maps.event.clearListeners(this.display, event);
  this.display.addListener(event, callback);
}

GISShape.prototype.listenToPath = function (event, callback) {
  google.maps.event.clearListeners(this.display.getPath(), event);
  this.display.getPath().addListener(event, callback);
}

GISShape.prototype.draw = function() {
  if (this.done) {
    this.erase();
    this.display = null;
  }

  this.display = this.line || !this.done
    ? GISPainter.drawPolyline(this)
    : GISPainter.drawPolygon(this);
}

GISShape.prototype.drawFinal = function() {
  this.done = true;
  this.draw();
}

GISShape.prototype.erase = function() {
  GISPainter.erase(this.markers);
  GISPainter.erase(this.display);
}

GISShape.prototype.updatePath = function (shape) {
  var path = JSON.stringify(shape.display.getPath().getArray())
  $.ajax({
    type: 'PUT',
    url: '/gis/shapes/' + shape.id,
    data: {
      gis_shape: { path: path }
    }
  })
}

GISShape.prototype.setColor = function() {
  if (this.archived) {
    var color = 'black';
  } else if (this.connection) {
    var color = 'blue';
  } else {
    var color = 'yellow'
  }
  this.display.setOptions({fillColor: color, strokeColor: color});
}
