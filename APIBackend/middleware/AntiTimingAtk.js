const crypto = require("crypto");

const AntiTiming = (req, res, next) => {
    // warning: this will let api request be extremely slow, 
    // do not use it in high-frequency requests!
    crypto.randomBytes(4, function(ex, buf) {
        let hex = buf.toString("hex");
        let randInt = parseInt(hex, 16);
        let delay = randInt % 1500
        setTimeout(() => {
            next();
        }, delay);
    });
}

module.exports = AntiTiming;