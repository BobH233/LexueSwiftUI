// 用于添加用户的deviceToken，群发apns消息等
const express = require("express");
const data_storage = require("../data_storage/data_storage");
const Logger = require("../utils/Logger");

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

module.exports = { registerDevice };
