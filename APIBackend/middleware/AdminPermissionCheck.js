const core_info = require("../private/core_info")


const CheckAdminToken = (req, res, next) => {
  let { adminToken } = req.body;
  if(!adminToken) {
    res.status(400).json({
      error: "This is admin only interface",
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return
  }
  if (adminToken != core_info.adminToken) {
    res.status(400).json({
      error: "Incorrect admin token",
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return;
  }
  next()
}

module.exports = CheckAdminToken;