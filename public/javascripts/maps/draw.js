var oCanvas = null;
var oCtx = null;
var cb_lastPoints = null;
var cb_easing = 0.4;
var _stylePaddingLeft = null;
var html = document.body.parentNode;
var _htmlTop = html.offsetTop;
var _htmlLeft = html.offsetLeft;


// Setup event handlers
window.onload = init
function init(e) {
	oCanvas = document.getElementById("thecanvas");
	_stylePaddingLeft = parseInt(document.defaultView.getComputedStyle(oCanvas, null)['paddingLeft'], 10)      || 0;
	_stylePaddingTop  = parseInt(document.defaultView.getComputedStyle(oCanvas, null)['paddingTop'], 10)       || 0;
	_styleBorderLeft  = parseInt(document.defaultView.getComputedStyle(oCanvas, null)['borderLeftWidth'], 10)  || 0;
	_styleBorderTop   = parseInt(document.defaultView.getComputedStyle(oCanvas, null)['borderTopWidth'], 10)   || 0;
	oCanvas.width= canWidth;
	oCanvas.height = canHeight;
	
	

	cb_lastPoints = Array();

	if (oCanvas.getContext) {
		oCtx = oCanvas.getContext('2d');
		oCtx.lineWidth = 5;
		oCtx.strokeStyle = "rgb(255, 0, 0)";
		oCtx.beginPath();

		var imageObj = new Image();
       	imageObj.src = imgPath;
       	imageObj.onload = function () {
           		oCtx.drawImage(imageObj, 0, 0);
       	};
		oCanvas.onmousedown = startDraw;
		oCanvas.onmouseup = stopDraw;
		
		
	}
}






function startDraw(e) {
	if (e.touches) {
		if(e.touches.length == 1){
			oCanvas.ontouchmove = drawMouse;
			oCanvas.ontouchstop = stopDraw;
			oCanvas.onmousedown = null
			oCanvas.onmouseup = null
			// Touch event
			for (var i = 1; i <= e.touches.length; i++) {
				cb_lastPoints[i] = getCoords(e.touches[i - 1]); // Get info for finger #1
			}
		}
	}
	else {
		// Mouse event
		cb_lastPoints[0] = getCoords(e);
		oCanvas.onmousemove = drawMouse;
	}
	
	return false;
}

// Called whenever cursor position changes after drawing has started
function stopDraw(e) {

		oCanvas.onmousemove = null;
}

function drawMouse(e) {
	if (e.touches) {
		// Touch Enabled
		for (var i = 1; i <= e.touches.length; i++) {
			var p = getCoords(e.touches[i - 1]); // Get info for finger i
			cb_lastPoints[i] = drawLine(cb_lastPoints[i].x, cb_lastPoints[i].y, p.x, p.y);
		}
	}
	else {
		// Not touch enabled
		var p = getCoords(e);
		cb_lastPoints[0] = drawLine(cb_lastPoints[0].x, cb_lastPoints[0].y, p.x, p.y);
	}
	oCtx.stroke();
	oCtx.closePath();
	oCtx.beginPath();

	return false;
}

// Draw a line on the canvas from (s)tart to (e)nd
function drawLine(sX, sY, eX, eY) {
	oCtx.moveTo(sX, sY);
	oCtx.lineTo(eX, eY);
	return { x: eX, y: eY };
}

// Get the coordinates for a mouse or touch event
function getCoords(e) {
	var toffsetX = 0, toffsetY = 0;
	// Compute the total offset
	var element = oCanvas;
  	if (element.offsetParent !== undefined) {
    		do {
      			toffsetX += element.offsetLeft;
      			toffsetY += element.offsetTop;
    		} while ((element = element.offsetParent));
 	}

	if (e.offsetX) {
		return { x: e.offsetX, y: e.offsetY };
	}
	else if (e.layerX) {
		return { x: e.layerX - (_stylePaddingLeft + _styleBorderLeft + _htmlLeft + toffsetX), y: e.layerY - (_stylePaddingTop + _styleBorderTop + _htmlTop + toffsetY ) };
	}
	else {
		return { x: e.pageX - (_stylePaddingLeft + _styleBorderLeft + _htmlLeft + toffsetX) , y: e.pageY - (_stylePaddingTop + _styleBorderTop + _htmlTop + toffsetY) };
	}
}



    function showDownloadText() {
        document.getElementById("buttoncontainer").style.display = "none";
        document.getElementById("textdownload").style.display = "block";
    }

    function hideDownloadText() {
        document.getElementById("buttoncontainer").style.display = "block";
        document.getElementById("textdownload").style.display = "none";
    }

    function saveCanvas(pCanvas, strType) {
        var bRes = false;
        if (strType == "PNG")
            bRes = Canvas2Image.saveAsPNG(oCanvas);

        if (!bRes) {
            alert("Sorry, this browser is not capable of saving " + strType + " files!");
            return false;
        }
    }

    document.getElementById("savepngbtn").onclick = function () {
        saveCanvas(oCanvas, "PNG");
    }

    function convertCanvas(strType) {
        if (strType == "PNG")
            var oImg = Canvas2Image.saveAsPNG(oCanvas, true);

        if (!oImg) {
            alert("Sorry, this browser is not capable of saving " + strType + " files!");
            return false;
        }

        oImg.id = "canvasimage";

        oImg.style.border = oCanvas.style.border;
        oCanvas.parentNode.replaceChild(oImg, oCanvas);

        showDownloadText();
    }



    document.getElementById("resetbtn").onclick = function () {
        var oImg = document.getElementById("thecanvas");
        oImg.parentNode.replaceChild(oCanvas, oImg);

        var oCtx = oCanvas.getContext("2d");
        //Clearing original drawing
        oCanvas.width = oCanvas.width;
        oCtx.clearRect(0, 0, oCanvas.width, oCanvas.height);

        var imageObj = new Image();
        imageObj.src = imgPath;
        imageObj.onload = function () {
            oCtx.drawImage(imageObj, 0, 0);
        };

        oCtx.beginPath();
        oCtx.strokeStyle = "rgb(255,0,0)";
        oCtx.lineWidth = "5";
        hideDownloadText();




    }
    function disableDrawing(){
	oCanvas.ontouchstart = null;
	oCanvas.ontouchstop = null;
	oCanvas.ontouchmove = null;
 	return false;
    }
    function enableDrawing(){
	oCanvas.ontouchstart = startDraw;
	return false;
    }

