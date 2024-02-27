const school_locations = require("../private/school_location");

const GetSchoolLocationsInfo = (req, res, next) => {
  res.json(school_locations);
};

module.exports = { GetSchoolLocationsInfo };
