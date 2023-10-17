const express = require("express");

const router = express.Router();

const DeviceController = require("../controllers/Device")

router.post("/register", require("../middleware/SignatureCheck"), DeviceController.registerDevice)

module.exports = router;