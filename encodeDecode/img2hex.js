/*============================
          ENCODING
  ===========================*/

// Require file system access
const FS = require('fs')

// Read file buffer 
let imgReadBuffer = FS.readFileSync("noah.jpg")

// Encode image buffer to hex
let imgHexEncode = new Buffer(imgReadBuffer).toString('hex')

// Output encoded data to console
console.log(imgHexEncode)

//Decode Hex
let imgHexDecode = new Buffer(imgHexEncode,'hex')

FS.writeFileSync('decodedHexImage.jpg', imgHexDecode)
