function GISConnection (params) {
  this.id = params.id || new Date().valueOf();
  this.saveType = params.id ? 'update' : 'create';
  this.gisItem = params.gisItem;
  this.type = params.type;
  this.html = null;
  this.menuLink = null;
}

GISConnection.prototype.setFields = function () {
  if (!this.html) {
    this.html = document.createElement('div');
    this.html.className = 'connection'
    this.html.id = this.id;

    var gisItemNamePrefix =
      GisConnector.state().recordName +
      '[' + GisConnector.state().attributeName + ']' +
      '[' + this.id + ']';

    if (this.saveType === 'update') {
      var idField = document.createElement('input');
      idField.type = 'hidden';
      idField.name = gisItemNamePrefix + '[id]';
      idField.value = this.id;
      this.html.appendChild(idField);

      var destroyField = document.createElement('input');
      destroyField.type = 'hidden';
      destroyField.name = gisItemNamePrefix + '[_destroy]';
      destroyField.className = 'destroy';
      this.html.appendChild(destroyField);
    } else {
      var gisItemTypeField = document.createElement('input');
      gisItemTypeField.type = 'hidden';
      gisItemTypeField.name = gisItemNamePrefix + '[gis_item_type]';
      gisItemTypeField.value = this.type;
      this.html.appendChild(gisItemTypeField);

      var gisItemIdField = document.createElement('input');
      gisItemIdField.type = 'hidden';
      gisItemIdField.name = gisItemNamePrefix + '[gis_item_id]';
      gisItemIdField.value = this.gisItem.id;
      this.html.appendChild(gisItemIdField);
    }
  }

  return this.html;
}

GISConnection.prototype.setMenuLink = function () {
  if (!this.menuLink) {
    this.menuLink = document.createElement('div');
    this.menuLink.className = 'btn btn-default';
    this.menuLink.style['width'] = 'auto';
    this.menuLink.style['min-height'] = '30px';
    this.menuLink.style['display'] = 'flex';
    this.menuLink.style['flex-direction'] = 'row-reverse';
    this.menuLink.style['flex-wrap'] = 'wrap';

    var title = document.createTextNode(this.gisItem.title);
    this.menuLink.appendChild(title);

    var this_ = this;
    this.menuLink.addEventListener('click', function(e) {
      GisConnector.includeLayer(this_.gisItem.layerId);
      GisConnector.openInfoWindow(this_.gisItem);
    });
  }

  return this.menuLink;
}

GISConnection.prototype.remove = function () {
  if (this.menuLink.parentNode) {
    this.menuLink.parentNode.removeChild(this.menuLink);
  }
  this.gisItem.connection = null;
  this.gisItem.setColor();

  if (!GisConnector.state().layers[this.gisItem.layerId].active) {
    this.gisItem.display.setVisible(false);
  }

  if (GisConnector.state().mode === 'remote') {
    // connection was already deleted
  } else if (this.saveType === 'update') {
    $(this.html).find('input.destroy').val(1);
  } else {
    $(this.html).remove();
  }
}
