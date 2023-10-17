// 用于添加用户的deviceToken，群发apns消息等
const express = require("express");
const data_storage = require("../data_storage/data_storage");
const core_info = require("../private/core_info")
const Logger = require("../utils/Logger");
var apn = require('@parse/node-apn');

var options = {
  token: {
    key: "./private/AuthKey_apns.p8",
    keyId: core_info.keyId,
    teamId: core_info.teamId
  },
  production: false
};
var apnProvider = new apn.Provider(options);


const DebugDevices = (req, res, next) => {
  let { adminToken, info } = req.body;
  if (adminToken != core_info.adminToken) {
    res.status(400).json({})
    return
  }
  // 向所有已注册的设备发送测试信息
  var note = new apn.Notification();
  let examplePayload = {
    command: "provider_new_message",
    for: "provider.info_merging",
    data: [
      {
        "link": "http://baidu.com/",
        "title": `(${Date.now}) ${info}`,
        "date": "2023-10-17T02:17:18.931Z",
        "source": "乐学助手"
      }
    ]
  }
  note.expiry = Math.floor(Date.now() / 1000) + 3600;
  note.badge = 0;
  note.contentAvailable = 1
  note.topic = "cn.bobh.LexueSwiftUI";
  note.pushType = 'background'
  note.payload = examplePayload;

  let devices = []
  let storedDevices = data_storage.getRegisteredDevices()
  for(const userId in storedDevices) {
    if (storedDevices.hasOwnProperty(userId)) {
      devices.push(storedDevices[userId].deviceToken)
    }
  }
  console.log(devices)
  apnProvider.send(note, deviceToken).then( (result) => {
    console.log(result);
  });
}

const registerDevice = async (req, res, next) => {
  try {
    let { data } = req.body;
    if (!data) {
      res.status(400).json({
        error: "No data specified",
      });
      return;
    }
    let { deviceToken } = data;
    let { userId } = req.body;
    if (!deviceToken) {
      res.status(400).json({
        error: "No deviceToken specified",
      });
      return;
    }
    if (!userId) {
      res.status(400).json({
        error: "No username specified",
      });
      return;
    }
    const currentDate = new Date();
    const currentDateString = currentDate.toLocaleString();
    data_storage.getRegisteredDevices()[userId] = {
      deviceToken,
      date: currentDateString,
    };
    data_storage.save_data();
    res.status(200).json({
      error: "Set device token successfully",
      qaq: "杂鱼❤杂鱼~~",
    });
    Logger.LogInfo(`用户${userId} 注册了消息接口 dtoken=${deviceToken}`)
  } catch (err) {
    next(err);
  }
};

module.exports = { registerDevice, DebugDevices };
