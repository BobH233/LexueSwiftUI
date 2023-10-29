const express = require("express");

const router = express.Router();

const NotificationController = require("../controllers/AppNotification")

router.get("/get", NotificationController.GetAppNotifications)

router.post("/add", require("../middleware/AdminPermissionCheck"), NotificationController.AddNewAppNotifications)

router.post("/edit", require("../middleware/AdminPermissionCheck"), NotificationController.EditAppNotifications)

router.post("/delete", require("../middleware/AdminPermissionCheck"), NotificationController.DeleteAppNotifications)

module.exports = router;