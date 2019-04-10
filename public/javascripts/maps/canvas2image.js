/*
 * Canvas2Image v0.1
 * Copyright (c) 2008 Jacob Seidelin, jseidelin@nihilogic.dk
 * MIT License [http://www.opensource.org/licenses/mit-license.php]
 */

var Canvas2Image = (function () {

    // check if we have canvas support
    var bHasCanvas = false;
    var oCanvas = document.createElement("canvas");
    if (oCanvas.getContext("2d")) {
        bHasCanvas = true;
    }

    // no canvas, bail out.
    if (!bHasCanvas) {
        return {
            saveAsPNG: function () { }
        }
    }

    var bHasImageData = !!(oCanvas.getContext("2d").getImageData);
    var bHasDataURL = !!(oCanvas.toDataURL);
    var bHasBase64 = !!(window.btoa);

    var strDownloadMime = "image/octet-stream";

    // ok, we're good
    var readCanvasData = function (oCanvas) {
        var iWidth = parseInt(oCanvas.width);
        var iHeight = parseInt(oCanvas.height);
        return oCanvas.getContext("2d").getImageData(0, 0, iWidth, iHeight);
    }

    // base64 encodes either a string or an array of charcodes
    var encodeData = function (data) {
        var strData = "";
        if (typeof data == "string") {
            strData = data;
        } else {
            var aData = data;
            for (var i = 0; i < aData.length; i++) {
                strData += String.fromCharCode(aData[i]);
            }
        }
        return btoa(strData);
    }

    

    // sends the generated file to the client
    var saveFile = function (strData) {
      document.getElementById('base64t').value = strData;
      document.getElementById('commit').click();
    }

    

    // generates a <img> object containing the imagedata
    var makeImageObject = function (strSource) {
        var oImgElement = document.createElement("img");
        oImgElement.src = strSource;
        return oImgElement;
    }

    var scaleCanvas = function (oCanvas, iWidth, iHeight) {
        if (iWidth && iHeight) {
            var oSaveCanvas = document.createElement("canvas");
            oSaveCanvas.width = iWidth;
            oSaveCanvas.height = iHeight;
            oSaveCanvas.style.width = iWidth + "px";
            oSaveCanvas.style.height = iHeight + "px";

            var oSaveCtx = oSaveCanvas.getContext("2d");

            oSaveCtx.drawImage(oCanvas, 0, 0, oCanvas.width, oCanvas.height, 0, 0, iWidth, iHeight);
            return oSaveCanvas;
        }
        return oCanvas;
    }

    return {

        saveAsPNG: function (oCanvas, bReturnImg, iWidth, iHeight) {
            if (!bHasDataURL) {
                return false;
            }
            var oScaledCanvas = scaleCanvas(oCanvas, iWidth, iHeight);
            var strData = oScaledCanvas.toDataURL("image/png");
            if (bReturnImg) {
                return makeImageObject(strData);
            } else {
                saveFile(strData);
            }
            return true;
        }

        
    };

})();
