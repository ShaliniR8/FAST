var GisLayerEditor = new function() {
  var handler = this,
      state = {
        map: null,
        clusterer: null,

        layersMenu: null,
        layers: {},
        activeLayer: null,

        optionsUI: null,
        editMode: false,
        shapeMode: false,

        markers: {},
        shapes: {},
        infoWindow: null,
        lineAnimationListener: null
      },
      markerIcon = {
        path: fontawesome.markers['CIRCLE'],
        fillColor: 'yellow',
        fillOpacity: 0.9,
        strokeColor: 'rgba(0,0,0, 0.5)',
        anchor: new google.maps.Point(30, -30),
        scale: 0.3
      },
      shapeIcon = {
        path: fontawesome.markers['CIRCLE'],
        fillColor: 'yellow',
        fillOpacity: 0.9,
        strokeColor: 'rgba(0,0,0, 0.5)',
        anchor: new google.maps.Point(30, -30),
        scale: 0.2
      };

  function changeLayerTo (layer) {
    if (state.activeLayer && state.activeLayer.id == layer.id)
      return;

    // Reset active marker and shapes
    GISPainter.reset();

    // set button UI as active
    state.activeLayer = layer;

    // Clear map of previous layer
    state.clusterer.clearMarkers();
    for (var i in state.shapes)
      state.shapes[i].erase();

    for (var id in state.layers) {
      if (layer.id == id)
        $(state.layers[id].ui).toggleClass('active');
      else
        $(state.layers[id].ui).removeClass('active');
    }

    $.getJSON('/gis/layers/' + layer.id, function(data) {
      state.markers = {};
      state.shapes = {};
      $.each(data.markers, function(i, markerData) {
        GisLayerEditor.drawMarker(markerData);
      });
      $.each(data.shapes, function(i, shapeData) {
        GisLayerEditor.drawShape(shapeData);
      });
      closeInfoWindow();
    }).fail(function(jqxhr){
      if (jqxhr.status == 404){
        alert('This GIS Layer does not exist.')
        $(layer.ui).remove();
      }
    });
  }

  function addLayer (layer) {
    var buttonUI = document.createElement('div');
    buttonUI.className = 'btn btn-default ml10';
    buttonUI.dataset.id = layer.id;
    buttonUI.style.width = 'auto';

    var titleText = document.createTextNode(layer.title);
    buttonUI.appendChild(titleText);

    var removeAction = document.createElement('a');
    removeAction.className = 'red pull-right ml10';
    removeAction.innerHTML = '<i class="fa fa-remove"></i>';
    buttonUI.appendChild(removeAction);

    var editAction = document.createElement('a');
    editAction.className = 'pull-right ml10';
    editAction.innerHTML = '<i class="fa fa-edit"></i>';
    buttonUI.appendChild(editAction);

    var layerState = {
      ui:    buttonUI,
      id:    layer.id,
      title: layer.title
    };

    removeAction.addEventListener('click', function(evt){
      evt.stopPropagation();
      removeLayer(layerState);
    });

    editAction.addEventListener('click', function(evt){
      evt.stopPropagation();
      swal({
        title: 'Rename Layer',
        input: 'text',
        inputValue: titleText.nodeValue,
        showCancelButton: true
      }).then(function(title) {
        renameLayer(layerState, title);
        titleText.nodeValue = title;
      });
    });

    buttonUI.addEventListener('click', function(){
      changeLayerTo(layerState);
    });

    state.layers[layerState.id] = layerState;
    state.layersMenu.appendChild(buttonUI);
  }

  function renameLayer (layerState, newTitle) {
    $.ajax({
      type: 'PUT',
      url: '/gis/layers/' + layerState.id,
      data: {
        'gis_layer': {
          'title': newTitle
        }
      }
    });
  }

  function removeLayer (layer) {
    if (confirm('Remove GIS Layer \'' + layer.title + '\'?'))
      $.ajax({
        type: 'DELETE',
        url: '/gis/layers/'+layer.id
      });
  }

  function toggleOption (option, overrideValue) {
    switch (option) {
      case 'editMode':
        state.editMode = overrideValue || !state.editMode;
        state.map.setOptions({ draggableCursor: (state.editMode ? 'crosshair' : '') });
        $('#gis-options :checkbox#editMode')
          .prop('checked', state.editMode);
        for (var id in state.markers) {
          state.markers[id].setDraggable(state.editMode)
        }
        for (var id in state.shapes) {
          state.shapes[id].setEditable(state.editMode)
        }
        break;
      case 'shapeMode':
        state.shapeMode = overrideValue || !state.shapeMode;
        $('#gis-options :checkbox#shapeMode')
          .prop('checked', state.shapeMode);
        break;
      default:
    }
  }

  this.state = function() {
    return state;
  }

  this.add = function(layer) {
    addLayer(layer);
  }

  // Initialize and draw Marker
  this.drawMarker = function(markerData) {
    var position = new google.maps.LatLng(
      parseFloat(markerData.lat),
      parseFloat(markerData.lng)
    );

    if (markerData.id in state.markers) {
      var marker = state.markers[markerData.id]
      marker.title = markerData.title
      marker.position = position
    } else {
      var marker = new GISMarker({
        type:      'marker-edit',
        id:        markerData.id,
        title:     markerData.title,
        layerId:   markerData.layer_id,
        position:  position,
        icon:      markerIcon
      });

      marker.draw();

      marker.setDraggable(state.editMode);
      marker.listen('click', function(e) {
        GISPainter.activeMarker.erase();
        openInfoWindow(marker);
      });

      state.markers[marker.id] = marker;
      state.clusterer.addMarker(marker.display);
    }

    return marker
  }

  // Initialize and draw Shape
  this.drawShape = function(shapeData) {
    if (shapeData.id in state.shapes) {
      var shape = state.shapes[shapeData.id]
      shape.title = shapeData.title
    } else {
      var shape = new GISShape({
        type:     'shape-edit',
        id:       shapeData.id,
        title:    shapeData.title,
        layerId:  shapeData.layer_id,
        line:     shapeData.line,
        done:     true,
      });

      for (var i in shapeData.markers) {
        var markerData = shapeData.markers[i];
        var position = new google.maps.LatLng(
          parseFloat(markerData.lat),
          parseFloat(markerData.lng)
        );
        shape.pushVertex(position);
      }

      shape.draw();

      shape.setEditable(state.editMode);
      shape.listen('click', function (e) {
        openInfoWindow(shape);
      });

      state.shapes[shape.id] = shape;
    }

    return shape
  }

  this.init = function(map, layers, infoWindow) {
    // Save Map information in state
    state.map = map;
    state.clusterer = new MarkerClusterer( map, [], {
      maxZoom: 19,
      imagePath: '/images/clusterer/m'
    });

    // Add GIS Layers menu to Google Map instance
    state.layersMenu = document.createElement('div');
    state.layersMenu.id = 'gis-layers';
    state.layersMenu.className = 'btn-group-vertical';
    state.layersMenu.style['max-height'] = map.getDiv().offsetHeight * 0.75 + 'px';
    state.layersMenu.style['overflow-y'] = 'auto';

    // Add GIS Layers menu header
    var containerHeader = document.createElement('div');
    containerHeader.style = 'pointer-events: none';
    containerHeader.className = 'btn btn-info ml10';
    containerHeader.innerText = 'GIS Layers';
    containerHeader.style.width = 'auto';
    state.layersMenu.appendChild(containerHeader);

    // Add GIS Layer Editing Options to Google Map Instance
    state.optionsUI = document.createElement('div');
    state.optionsUI.id = 'gis-options';
    state.optionsUI.className = 'btn-group-vertical';
    state.optionsUI.style['max-height'] = map.getDiv().offsetHeight * 0.75 + 'px';
    state.optionsUI.style['overflow-y'] = 'auto';

    // Add Options header
    var optionsHeader = document.createElement('div');
    optionsHeader.style = 'pointer-events: none';
    optionsHeader.className = 'btn btn-warning mr10';
    optionsHeader.innerText = 'Options';
    optionsHeader.style.width = 'auto';
    state.optionsUI.appendChild(optionsHeader);

    // Add Edit Mode Option
    var editModeUI = document.createElement('div');
    editModeUI.className = 'btn btn-default mr10';
    editModeUI.innerHTML = '<input id="editMode" type="checkbox"> Edit Mode';
    editModeUI.style.width = 'auto';
    editModeUI.addEventListener('click', function(){
      toggleOption('editMode');
    })
    state.optionsUI.appendChild(editModeUI);

    // Add Shape Mode Option
    var shapeModeUI = document.createElement('div');
    shapeModeUI.className = 'btn btn-default mr10';
    shapeModeUI.innerHTML = '<input id="shapeMode" type="checkbox"> Shape Mode';
    shapeModeUI.style.width = 'auto';
    shapeModeUI.addEventListener('click', function(){
      toggleOption('shapeMode');
    })
    state.optionsUI.appendChild(shapeModeUI);

    map.controls[google.maps.ControlPosition.LEFT_TOP].push(state.layersMenu)
    map.controls[google.maps.ControlPosition.RIGHT_TOP].push(state.optionsUI);
    map.addListener('click', function (e) {
      if (state.editMode) {
        state.shapeMode ? addNewShape(e.latLng) : addNewMarker(e.latLng);
      } else {
        closeInfoWindow();
      }
    });
    map.addListener('rightclick', function(e) {
      closeInfoWindow();
    });

    GISPainter.init(map);
    state.infoWindow = infoWindow || new google.maps.InfoWindow();

    $.each(layers, function(i, layer){
      addLayer(layer);
    });

    // Open first layer on start
    if (layers.length > 0)
      changeLayerTo(layers[0]);

    // Prevents a map pin from being dropped when zooming into a cluster
    google.maps.event.addListener(state.clusterer, 'clusterclick', function(cluster){
      event.cancelBubble = true;
    })

    $.ajaxSetup({
      beforeFilter: function (xhr) {
        var token = $('meta[name="csrf-token"]').attr('content');
        xhr.setRequestHeader('X-CSRF-Token', token);
      }
    });
  }

  // Draw new marker on map from mouse click
  function addNewMarker (position) {
    if (!GISPainter.activeMarker.display) {
      GISPainter.activeMarker = new GISMarker({
        type:      'marker-new',
        title:     '',
        layerId:   state.activeLayer.id,
        position:  position,
        icon:      markerIcon
      });
    }

    GISPainter.activeMarker.draw(position);
    GISPainter.activeMarker.display.addListener('click', function(e) {
      GISPainter.erase(GISPainter.activeMarker.display);
      closeInfoWindow();
    });
    openInfoWindow(GISPainter.activeMarker);
  }

  // Draw new shape on map from mouse right click.
  function addNewShape (position) {
    if (!GISPainter.activeShape.display) {
      GISPainter.activeShape = new GISShape({
        type:    'shape-new',
        layerId: state.activeLayer.id
      });
    }

    // Close previous active shape if it's done
    if (GISPainter.activeShape.done) {
      GISPainter.activeShape.erase();
      GISPainter.activeShape = new GISShape({
        type:    'shape-new',
        layerId: state.activeLayer.id
      });
      closeInfoWindow();
    }

    // Remove previous active line animation
    google.maps.event.removeListener(state.lineAnimationListener);
    GISPainter.erase(GISPainter.activeAnimatedline);

    // Finish drawing a shape when 1st marker is clicked again
    if (GISPainter.activeShape.length() > 2 && isPositionSame(GISPainter.activeShape.paths[0], position)) {
      console.log('finish')
      GISPainter.activeShape.drawFinal();
      openInfoWindow(GISPainter.activeShape);
      return;
    }

    // Remove previous marker/vertex if it's clicked again. Otherwise, create a new marker/vertex.
    if (GISPainter.activeShape.length() > 0 && isPositionSame(GISPainter.activeShape.paths[GISPainter.activeShape.length() - 1], position)) {
      GISPainter.erase(GISPainter.activeShape.markers.pop());
      GISPainter.activeShape.popVertex();
      if (GISPainter.activeShape.length() == 0)
        return;
      position = GISPainter.activeShape.paths[GISPainter.activeShape.length() - 1];
    } else {
      var marker = GISPainter.drawMarker({
        position: position,
        icon: shapeIcon
      });
      marker.addListener('click', function(e) {
        if (state.shapeMode)
          addNewShape(marker.position);
      });
      GISPainter.activeShape.markers.push(marker);
      GISPainter.activeShape.pushVertex(position);
    }

    // Draw current shape and animated line
    GISPainter.activeShape.draw();
    state.lineAnimationListener = state.map.addListener('mousemove', function(e) {
      GISPainter.activeAnimatedline = GISPainter.drawPolyline({
        paths: [position, e.latLng],
        display: GISPainter.activeAnimatedline,
        clickable: false
      });
    });
  }

  // Open info window based on the element type
  function openInfoWindow (element) {
    state.infoWindow.setContent('Loading...');
    state.infoWindow.setPosition(element.getPosition());
    state.infoWindow.open(state.map);

    switch(element.type) {
      case 'marker-new':
        $.get('/gis/markers/new.js');
        break;
      case 'marker-edit':
        $.get('/gis/markers/' + element.id + '/edit.js')
        break;
      case 'shape-new':
        $.get('/gis/shapes/new.js');
        break;
      case 'shape-edit':
        $.get('/gis/shapes/' + element.id + '/edit.js')
        break;
    }
  }

  // Close marker window
  function closeInfoWindow () {
    state.infoWindow.close();
  }

  // Check if positions are the same
  function isPositionSame (pos1, pos2) {
    return pos1.lat() === pos2.lat()
        && pos1.lng() === pos2.lng();
  }
}
