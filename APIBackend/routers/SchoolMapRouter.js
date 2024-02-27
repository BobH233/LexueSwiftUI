const express = require("express");

const router = express.Router();

const SchoolMapController = require("../controllers/SchoolMapController")

router.get("/locations", SchoolMapController.GetSchoolLocationsInfo)

module.exports = router;