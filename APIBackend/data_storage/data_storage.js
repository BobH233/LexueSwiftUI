const fs = require('fs');
const path = require('path');
const Logger = require("../utils/Logger");

// 用户名 -> 设备token
let RegisteredDevices = {

}

// 已经拉取过的HaoBIT信息，用于diff
// InfoHash -> true
let FetchedMessages = {

}

const RegisteredDevicesPath = path.join(__dirname, '..', 'server_data', 'RegisteredDevices.json');
const FetchedMessagesPath = path.join(__dirname, '..', 'server_data', 'FetchedMessages.json');

const load_data = () => {
  
  Logger.LogInfo(RegisteredDevicesPath)
  Logger.LogInfo(FetchedMessagesPath)

  if(!fs.existsSync(RegisteredDevicesPath)) {
    fs.writeFileSync(RegisteredDevicesPath, "{}");
  } else {
    RegisteredDevices = JSON.parse(fs.readFileSync(RegisteredDevicesPath));
  }
  if(!fs.existsSync(FetchedMessagesPath)) {
    fs.writeFileSync(FetchedMessagesPath, "{}");
  } else {
    FetchedMessages = JSON.parse(fs.readFileSync(FetchedMessagesPath));
  }
  Logger.LogInfo("Load data finished.");
}

const save_data = () => {
  console.log(RegisteredDevices)
  fs.writeFileSync(RegisteredDevicesPath, JSON.stringify(RegisteredDevices));
  fs.writeFileSync(FetchedMessagesPath, JSON.stringify(FetchedMessages));
  Logger.LogInfo("Save data finished.");
}

module.exports = {
  getRegisteredDevices: () => RegisteredDevices,
  getFetchedMessages: () => FetchedMessages,
  load_data,
  save_data
}