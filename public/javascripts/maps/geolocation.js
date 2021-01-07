var MapTracker = new function() {
  var tracker = this,
      state = {
        buttonUI: null,
        map: null,
        originalCenter: null,
        watchId: null,
      };

  var centerMapToMe = function(position) {
    var lat = position.coords.latitude,
        lng = position.coords.longitude;
    state.map.setCenter(new google.maps.LatLng(lat, lng));
  }

  var turnOff = function() {
    navigator.geolocation.clearWatch(state.watchId);
    state.map.setCenter(state.originalCenter);
    $(state.buttonUI).text("Enable GPS Tracking");
    state.watchId = null;
  }

  var turnOn = function() {
    $(state.buttonUI).text("Disable GPS Tracking");
    state.watchId = navigator.geolocation.watchPosition(centerMapToMe, function(){
      console.error("an error occurred!")
      turnOff();
    }, { enableHighAccuracy: true });
  }

  this.state = function() {
    return state;
  }

  this.init = function(map) {
    if (!navigator.geolocation)
      throw "This browser does not support geolocation."

    // Add Button UI to Google Map instance
    var buttonUI = document.createElement("div");
    buttonUI.className = "btn btn-default mt10";
    buttonUI.innerText = "Enable GPS Tracking";

    var container = document.createElement("div");
    container.appendChild(buttonUI);
    map.controls[google.maps.ControlPosition.TOP_CENTER].push(container);

    // Save Map information in state
    state.buttonUI = buttonUI;
    state.map = map;
    state.originalCenter = map.getCenter();

    buttonUI.addEventListener("click", function(){
      state.watchId ? turnOff() : turnOn();
    });
  }
}
