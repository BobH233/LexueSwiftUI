const Logger = require("../utils/Logger");
const CodeErrorRouter = (err, req, res, next) => {
    Logger.LogError(`Request ${req.method} ${req.originalUrl} caused error: ${err.message}`);
    Logger.LogError(`Stacktrace: ${err.stack}`);
    const code = err.status || 500;
    const reason = err.message || "Unknown error";
    return res.status(code).json({
        code,
        message: `internal code error.(${reason})`
    });
}

module.exports = CodeErrorRouter;