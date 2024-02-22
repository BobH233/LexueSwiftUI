const express = require("express");

const router = express.Router();

const ScheduleController = require("../controllers/ScheduleController")

router.get("/sectioninfo", ScheduleController.GetScheduleSectionInfo)

router.get("/cursemester", ScheduleController.GetCurrentSemester)

module.exports = router;