// 获取haobit的消息更新
const data_storage = require("../data_storage/data_storage");
const core_info = require("../private/core_info");
const Logger = require("../utils/Logger");

// 拉取指定hash之后的数据
const FetchLatestNotice = (req, res, next) => {
  let { data } = req.body;
  if(!data) {
    res.status(400).json({
      error: "No data specified",
    });
    return;
  }
  let { afterHash } = data;
  const response_with_data = (data) => {
    data_storage._GetLatestHaoBITNotificationHash((hash, err) => {
      if(err) {
        next(err);
        return;
      }
      res.json({
        latestHash: hash,
        data
      });
    })
  }
  if(!afterHash) {
    response_with_data([]);
    return;
  }
  // 寻找是否有指定的afterHash
  data_storage._QueryHaoBITNotificationByHash(afterHash, (rows, err) => {
    if(err) {
      next(err);
      return;
    }
    if(rows.length == 0) {
      response_with_data([]);
      return;
    }
    data_storage._QueryHaoBITNotificationsAfterId(rows[0]['id'], (rows, err) => {
      if(err) {
        next(err);
        return;
      }
      let data = [];
      for(let j=0;j<rows.length;j++){
        data.push(JSON.parse(rows[j]['jsonStr']));
      }
      response_with_data(data);
    })
  })
}

module.exports = { FetchLatestNotice };