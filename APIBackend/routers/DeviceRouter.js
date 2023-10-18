const express = require("express");

const router = express.Router();

const DeviceController = require("../controllers/Device")

router.post("/register", require("../middleware/SignatureCheck"), DeviceController.registerDevice)

router.post("/debug", require("../middleware/AntiTimingAtk"), DeviceController.DebugDevices)

module.exports = router;