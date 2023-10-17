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

let examplePayload = {
  command: "provider_new_message",
  for: "provider.info_merging",
  data: [
    {
      "link": "http://mp.weixin.qq.com/s/cJQ7lOTUm9fQtfnmm0IhqQ",
      "title": "1123访",
      "date": "2023-10-17T02:17:18.931Z",
      "source": "留学生"
    },
    {
      "link": "http://mp.weixin.qq.com/s/cJQ7lOTUm9fQtfnmm0IhqQ",
      "title": "1421",
      "date": "20231-10-17T02:17:18.931Z",
      "source": "留学生"
    }
  ]
}

note.expiry = Math.floor(Date.now() / 1000) + 3600; // Expires 1 hour from now.
note.badge = 0;
note.contentAvailable = 1
note.sound = "ping.aiff";
note.alert = "\uD83D\uDCE7 \u2709 You have a new message";
note.payload = examplePayload;
note.topic = "cn.bobh.LexueSwiftUI";
note.pushType = 'background'



apnProvider.send(note, deviceToken).then( (result) => {
  console.log(result);
});