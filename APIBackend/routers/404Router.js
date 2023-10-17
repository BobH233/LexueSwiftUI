const Logger = require("../utils/Logger");
const NotFoundRouter = (req, res, next) => {
    Logger.LogWarn(`Request ${req.method} ${req.originalUrl} not found!`);
    res.status(404).send(JSON.stringify({
        code: 404,
        message: "invalid api router."
    }));
}

module.exports = NotFoundRouter;