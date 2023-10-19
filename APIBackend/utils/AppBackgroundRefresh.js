const express = require("express");
const data_storage = require("../data_storage/data_storage");
const core_info = require("../private/core_info");
const Logger = require("../utils/Logger");
const Apns = require("../utils/Apns");
var apn = require("apn");

const SendRefreshCommand = () => {
  Logger.LogInfo("发送后台刷新apns信息...")
  var note = new apn.Notification();
  let examplePayload = {
    command: "refresh_data_provider",
  };
  note.expiry = Math.floor(Date.now() / 1000) + 3600;
  note.badge = 0;
  note.contentAvailable = 1;
  note.topic = "cn.bobh.LexueSwiftUI";
  note.pushType = "background";
  note.payload = examplePayload;
  Apns.SendToAllDevices(note, (result, err) => {
    if (err) {
      Logger.LogError("发送后台刷新apns信息失败")
      console.log(err);
      return;
    }
    Logger.LogInfo(`发送成功, 成功设备: ${result.sent?.length}, 失败设备: ${result.failed?.length}`)
  });
};

const SetIntervalForRefresh = () => {
  Logger.LogInfo("设定发送App定时更新定时器...")
  setInterval(() => {
    SendRefreshCommand();
  }, 60 * 60 * 1000); // 一小时刷新一次app
};

module.exports = {
  SetIntervalForRefresh,
};
