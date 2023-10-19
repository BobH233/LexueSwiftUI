
const data_storage = require("../data_storage/data_storage");
const core_info = require("../private/core_info");
var apn = require("apn");
const Logger = require("../utils/Logger");



console.log("apns production: " + !process.env.APN_PRODUCTION)
var options = {
  token: {
    key: "./private/AuthKey_new.p8",
    keyId: core_info.keyId,
    teamId: core_info.teamId
  },
  production: process.env.APN_PRODUCTION == "true",
};
var apnProvider = new apn.Provider(options);

const SendToAllDevices = (notification, CB) => {
  data_storage._GetAllRegisteredDevices((rows, err) => {
    let devices = [];
    if (err) {
      CB(null, err);
      return;
    }
    let failedCountMap = {};
    for (let i = 0; i < rows.length; i++) {
      devices.push(rows[i]["DeviceToken"]);
      failedCountMap[rows[i]["DeviceToken"]] = parseInt(rows[i]["FailCount"])
    }
    // console.log(failedCountMap)
    apnProvider.send(notification, devices).then((result) => {
      
      // 判断失败的设备，增加1；成功的设备置零；如果失败次数已经超过了5次，则删除该设备不再推送
      let failedDevice = result.failed;
      let successDevice = result.sent;
      let deleteList = [];
      let resetList = [];
      for(let i=0;i<failedDevice.length;i++) {
        let currentDeviceToken = failedDevice[i].device
        if(failedCountMap[currentDeviceToken] != undefined) {
          failedCountMap[currentDeviceToken]++;
          if(failedCountMap[currentDeviceToken] > 5) {
            deleteList.push(currentDeviceToken)
          } else {
            // 更新这个设备失败数
            data_storage._UpdateDeviceFailCount(currentDeviceToken, failedCountMap[currentDeviceToken], (err)=> {
              if(err) console.log("更新单个设备失败次数失败", err);
            })
          }
        }
      }
      for(let i=0;i<successDevice.length;i++) {
        resetList.push(successDevice[i].device)
      }
      data_storage._DeleteBatchRegisteredDevices(deleteList, (err) => {
        if(err) {
          console.log("删除记录出错", err)
        }
      })
      data_storage._ResetBatchDeviceFailedCount(resetList, (err) => {
        if(err) {
          console.log("重置记录出错", err)
        }
      })
      CB(result, null);
    });
  });
}

module.exports = {
  SendToAllDevices,
}