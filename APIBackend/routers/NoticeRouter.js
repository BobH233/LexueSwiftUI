const express = require("express");

const router = express.Router();

const NoticeController = require("../controllers/Notice")

router.post("/fetch", require("../middleware/SignatureCheck"), NoticeController.FetchLatestNotice)


module.exports = router;