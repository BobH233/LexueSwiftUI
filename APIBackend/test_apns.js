var apn = require('@parse/node-apn');
const core_info = require('./private/core_info')
const debug = require('./private/debug')


var options = {
  token: {
    key: "private/AuthKey_apns.p8",
    keyId: core_info.keyId,
    teamId: core_info.teamId
  },
  production: false
};

var apnProvider = new apn.Provider(options);

let deviceToken = debug.myDeviceId;

var note = new apn.Notification();

note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
note.badge = 0;
note.sound = "ping.aiff";
note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
note.payload = {'messageFrom': 'John Appleseed'};
note.topic = "cn.bobh.LexueSwiftUI";

apnProvider.send(note, deviceToken).then( (result) => {
  console.log(result);
});