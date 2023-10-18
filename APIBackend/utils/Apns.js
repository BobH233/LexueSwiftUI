
const data_storage = require("../data_storage/data_storage");
const core_info = require("../private/core_info");
var apn = require("@parse/node-apn");

var options = {
  token: {
    key: "./private/AuthKey_apns.p8",
    keyId: core_info.keyId,
    teamId: core_info.teamId,
  },
  production: !process.env.LOCALDEV,
};
var apnProvider = new apn.Provider(options);

const SendToAllDevices = (notification, CB) => {
  data_storage._GetAllRegisteredDevices((rows, err) => {
    let devices = [];
    if (err) {
      CB(null, err);
      return;
    }
    for (let i = 0; i < rows.length; i++) {
      devices.push(rows[i]["DeviceToken"]);
    }
    apnProvider.send(notification, devices).then((result) => {
      CB(result, null);
    });
  });
}

module.exports = {
  SendToAllDevices,
}