var GisConnector = new function () {
  var handler = this,
      state = {
        mode: 'viewOnly',
        attachTo: null,
        recordName: '',
        attributeName: '',
        connectionParams: null,
        showSimilarRecords: false,
        similarRecordFilters: {},

        map: null,
        clusterer: null,
        layersMenu: null,
        layers: {},
        connectionsMenu: null,
        connections: {},
        infoWindow: null,
      },
      icon = {
        path: fontawesome.markers['CIRCLE'],
        fillColor: 'yellow',
        fillOpacity: 0.9,
        strokeColor: 'rgba(0,0,0, 0.5)',
        anchor: new google.maps.Point(30, -30),
        scale: 0.3
      };

  /* Initialize GIS Connector
  **
  ** Options:
  **   - mode: how Connector interacts with page. Options:
  **     - 'viewOnly': only display information
  **     - 'inline': connections are saved to an HTML form
  **     - 'remote': connections are saved via AJAX
  **   - connectionParams: params to query existing Connections
  **   - attachTo (inline): CSS selector of parent to append connection fields
  **   - recordName (inline): prefix of connection field `name` attribute
  **   - attributeName (inline): main object of connection `name` attribute`
  **     - only if fields_for expects a different name than `gis_connections_attributes`
  **   - recordType (remote): value to be passed to Connection `record_type`
  **   - recordId (remote): value to be passed to Connection `record_id`
  **   - infoWindow: InfoWindow used in map, if already defined
  */
  this.init = function (map, options) {
    options = options || {};
    state.mode = options.mode;
    state.infoWindow = state.infoWindow ||
                      options.infoWindow ||
                      new google.maps.InfoWindow();
    state.connectionParams = options.connectionParams;
    state.showSimilarRecords = options.showSimilarRecords || {};
    state.similarRecordFilters = options.similarRecordFilters;
    state.attributeName = options.attributeName || 'gis_connections_attributes';
    if (state.mode === 'inline') {
      state.attachTo = options.attachTo;
      state.recordName = options.recordName;
    } else if (state.mode === 'remote') {
      state.recordType = options.recordType;
      state.recordId = options.recordId;
    }

    // Save Map information in state
    state.map = map;
    state.clusterer = new MarkerClusterer( map, [], {
      maxZoom: 19,
      imagePath: '/images/clusterer/m',
      gridSize: 30
    });

    if (!state.layersMenu) {
      $.getJSON('/gis/layers', function (layers) {
        // Add GIS Layers menu to Google Map instance
        state.layersMenu = document.createElement('div');
        state.layersMenu.id = 'gis-layers';
        state.layersMenu.style.display = 'block';
        state.layersMenu.className = 'btn-group-vertical ml10';
        state.layersMenu.style['max-height'] = map.getDiv().offsetHeight * 0.75 + 'px';
        state.layersMenu.style['overflow-y'] = 'auto';

        // Add GIS Layers menu header
        var layersHeader = document.createElement('div');
        layersHeader.style = 'pointer-events: none';
        layersHeader.className = 'btn btn-info';
        layersHeader.innerText = 'GIS Layers';
        layersHeader.style.width = 'auto';
        state.layersMenu.appendChild(layersHeader);

        // Load Active GIS Layers
        $.each(layers, function (i, layer) {
          addLayer(layer);
        });

        map.controls[google.maps.ControlPosition.LEFT_TOP].push(state.layersMenu);

        GisConnector.loadConnections();
      });
    }

    // Add GIS Connections menu to Google Map instance
    state.connectionsMenu = document.createElement('div');
    state.connectionsMenu.id = 'gis-layers';
    state.connectionsMenu.className = 'btn-group-vertical mr10';
    state.connectionsMenu.style['max-height'] = map.getDiv().offsetHeight * 0.75 + 'px';
    state.connectionsMenu.style['overflow-y'] = 'auto';

    // Add GIS Connections menu header
    var connectionsHeader = document.createElement('div');
    connectionsHeader.style = 'pointer-events: none';
    connectionsHeader.className = 'btn btn-success';
    connectionsHeader.innerText = 'GIS Linked Features';
    connectionsHeader.style.width = 'auto';
    state.connectionsMenu.appendChild(connectionsHeader);

    map.controls[google.maps.ControlPosition.RIGHT_TOP].push(state.connectionsMenu);
    map.addListener('rightclick', function (e) {
      GisConnector.closeInfoWindow();
    });

    GISPainter.init(map);

    // Prevents a map pin from being dropped when zooming into a cluster
    google.maps.event.addListener(state.clusterer, 'clusterclick', function (cluster) {
      event.cancelBubble = true;
    });
  }

  this.loadConnections = function () {
    if (state.connectionParams) {
      switch (typeof state.connectionParams) {
        case 'function':
          var connectionParams = state.connectionParams();
          break;
        default:
          var connectionParams = state.connectionParams;
      }

      $.getJSON('/gis/connections', connectionParams, function (data) {
        data.forEach(function (conn) {
          if (!(conn.id in state.connections)) {
            var layer = state.layers[conn.gis_item.layer_id];

            // create GIS Marker/Shape if not present
            switch (conn.gis_item_type) {
              case 'Gis::Marker':
                layer.markers = layer.markers || {};
                if (!(conn.gis_item_id in layer.markers)) {
                  var gisItem = createMarker(conn.gis_item);
                  layer.markers[conn.gis_item_id] = gisItem;
                }
                break;
              case 'Gis::Shape':
                layer.shapes = layer.shapes || {};
                if (!(conn.gis_item_id in layer.shapes)) {
                  var gisItem = createShape(conn.gis_item);
                  layer.shapes[conn.gis_item_id] = gisItem;
                }
                break
            }

            // add GIS Connection
            GisConnector.addConnection(new GISConnection({
              id: conn.id,
              type: conn.gis_item_type,
              gisItem: gisItem
            }));
          }
        });
      });
    }
  }

  this.includeLayer = function (layerId) {
    var layer = state.layers[layerId];

    if (layer && !layer.active) {
      loadLayerData(layerId).then(function () {
        for (var id in layer.markers) {
          var marker = layer.markers[id];
          state.clusterer.addMarker(marker.display);
          marker.display.setVisible(true);
        }
        for (var id in layer.shapes) {
          var shape = layer.shapes[id];
          shape.display.setVisible(true);
        }

        layer.ui.classList.add('active');
        layer.active = true;
      });
    }
  }

  this.excludeLayer = function (layerId) {
    var layer = state.layers[layerId];
    layer.ui.classList.remove('active');

    for (var id in layer.markers) {
      var marker = layer.markers[id];
      state.clusterer.removeMarker(marker.display);
      marker.display.setVisible(false);
    }

    for (var id in layer.shapes) {
      var shape = layer.shapes[id];
      shape.display.setVisible(false);
    }

    layer.active = false;
  }

  function loadLayerData (layerId) {
    return new Promise(function (resolve, reject) {
      if (state.layers[layerId].loaded) {
        resolve();
      } else {
        $.getJSON('/gis/layers/' + layerId, function (data) {
          state.layers[layerId].markers = state.layers[layerId].markers || {};
          state.layers[layerId].shapes = state.layers[layerId].shapes || {};

          $.each(data.markers, function (i, marker) {
            if (!(marker.id in state.layers[layerId].markers)) {
              state.layers[layerId].markers[marker.id] = createMarker(marker);
            }
          });

          $.each(data.shapes, function (i, shape) {
            if (!(shape.id in state.layers[layerId].shapes)) {
              state.layers[layerId].shapes[shape.id] = createShape(shape);
            }
          });

          state.layers[layerId].loaded = true;
          resolve();
        }).fail(function (jqxhr) {
          if (jqxhr.status == 404) {
            alert('This GIS Layer does not exist.')
            $(layer.ui).remove();
          }
        });
      }
    });
  }

  function addLayer (layerData) {
    var buttonUI = document.createElement('div');
    buttonUI.className = 'btn btn-default';
    buttonUI.dataset.id = layerData.id;
    buttonUI.style.width = 'auto';

    var layerState = {
      ui:     buttonUI,
      id:     layerData.id,
      title:  layerData.title,
      active: false
    };
    state.layers[layerData.id] = layerState;

    var titleText = document.createTextNode(layerData.title);
    buttonUI.appendChild(titleText);
    buttonUI.addEventListener('click', function () {
      if (buttonUI.classList.contains('active')) {
        GisConnector.excludeLayer(layerState.id);
      } else {
        GisConnector.includeLayer(layerState.id);
      }
      GisConnector.closeInfoWindow();
    });

    state.layersMenu.appendChild(buttonUI);
  }

  this.state = function () {
    return state;
  }

  this.isViewOnly = function () {
    return state.mode === 'viewOnly'
  }

  this.toggle = function (state) {
    state ? this.show() : this.hide()
  }

  this.show = function () {
    for (var id in state.connections) {
      state.connections[id].gisItem.display.setVisible(true);
    }
    if (state.layersMenu) {
      state.layersMenu.style.display = 'block';
    }
    if (state.connectionsMenu) {
      state.connectionsMenu.style.display = 'block';
    }
  }

  this.hide = function () {
    for (var id in state.connections) {
      state.connections[id].gisItem.display.setVisible(false);
    }
    if (state.layersMenu) {
      state.layersMenu.style.display = 'none';
    }
    if (state.connectionsMenu) {
      state.connectionsMenu.style.display = 'none';
    }
    this.closeInfoWindow();
  }

  this.setMap = function (map) {
    state.map = map;
    map.controls[google.maps.ControlPosition.LEFT_TOP].push(state.layersMenu);
    map.controls[google.maps.ControlPosition.RIGHT_TOP].push(state.connectionsMenu);
    map.addListener('rightclick', function (e) {
      GisConnector.closeInfoWindow();
    });
    GisPainter.map = map;
    for (var layerId in this.layers) {
      var layer = this.layers[layerId];
      for (var id in layer.markers) {
        layer.markers[id].display.setMap(map);
      }
      for (var id in layer.shapes) {
        layer.shapes[id].display.setMap(map);
      }
    }
  }

  this.addConnection = function (connection) {
    state.connections[connection.id] = connection;
    connection.gisItem.connection = connection;
    connection.gisItem.setColor();
    state.connectionsMenu.appendChild(connection.setMenuLink());
    if (state.mode === 'inline') {
      document.querySelector(state.attachTo).appendChild(connection.setFields());
    }
  }

  this.removeConnection = function (connection) {
    state.connections[connection.id].remove();
    delete state.connections[connection.id];
  }

  this.findConnection = function (filter) {
    for (var id in state.connections) {
      if (filter(state.connections[id])) {
        return state.connections[id]
      }
    }
    return null
  }

  // Draw existing marker on map with marker data
  function createMarker (markerData) {
    var position = new google.maps.LatLng(
      parseFloat(markerData.lat),
      parseFloat(markerData.lng)
    );

    var marker = new GISMarker({
      type:      'marker-link',
      id:        markerData.id,
      title:     markerData.title,
      layerId:   markerData.layer_id,
      position:  position,
      icon:      icon,
      archived:  markerData.archived
    });

    marker.draw();
    marker.listen('click', function (e) {
      GisConnector.openInfoWindow(marker);
    });

    return marker;
  }

  // Draw existing shape on map with shape data
  function createShape (shapeData) {
    var shape = new GISShape({
      type:     'shape-link',
      id:       shapeData.id,
      title:    shapeData.title,
      layerId:  shapeData.layer_id,
      line:     shapeData.line,
      done:     true,
      archived: shapeData.archived
    });

    shapeData.markers = shapeData.markers || [];

    for (var i in shapeData.markers) {
      var markerData = shapeData.markers[i];
      var position = new google.maps.LatLng(
        parseFloat(markerData.lat),
        parseFloat(markerData.lng)
      );
      shape.pushVertex(position);
    }

    shape.draw();
    shape.listen('click', function (e) {
      GisConnector.openInfoWindow(shape);
    });

    return shape;
  }

  // Open info window based on the element type
  this.openInfoWindow = function (element) {
    state.infoWindow.setContent('Loading...');
    state.infoWindow.setPosition(element.getPosition());
    state.infoWindow.open(state.map);
    state.map.panTo(element.getPosition());

    if (state.mode !== 'inline' && element.connection) {
      // load Connection information
      $.get(
        '/gis/connections/' + element.connection.id, {
        show_similar_records: state.showSimilarRecords,
        similar_record_filters: state.similarRecordFilters
      })
    } else if (element.type === 'marker-link') {
      // load Marker information
      $.get('/gis/markers/' + element.id)
    } else if (element.type === 'shape-link') {
      // load Shape information
      $.get('/gis/shapes/' + element.id)
    }
  }

  // Close marker window
  this.closeInfoWindow = function () {
    state.infoWindow.close();
  }
}
