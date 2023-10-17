const Logger = require("../utils/Logger");
const LogRequest = (req, res, next) => {
    Logger.LogInfo(`Request ${req.method} ${req.originalUrl}`);
    next();
}

module.exports = LogRequest;