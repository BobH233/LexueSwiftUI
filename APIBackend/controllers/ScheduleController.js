const core_info = require("../private/core_info");

const GetScheduleSectionInfo = (req, res, next) => {
  res.json(core_info.scheduleSectionInfo);
};

const GetCurrentSemester = (req, res, next) => {
  res.json({
    semester: core_info.currentSemester,
  });
};

module.exports = { GetScheduleSectionInfo, GetCurrentSemester };
