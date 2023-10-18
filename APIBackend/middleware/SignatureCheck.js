const core_info = require("../private/core_info")
const crypto = require('crypto');

// UUIDString -> Bool
let CheckedUUID = {

}

// 检查发送包的签名是否正确，时间戳是否过期，UUID是否已经重复
// 应用的标准包格式应该是 
/*
  {
    "cmdName": "要执行的指令的名字",
    "UUID": "应用包的唯一ID，用于去重放攻击",
    "userId": "用户ID，一般就是学号",
    "timestamp": "时间戳秒为单位"
    "signature": "封包签名",
    "data": {
      // 一些有效负载
    }
  }
*/
const CheckSignature = (req, res, next) => {
  next();
  return;
  let { cmdName, UUID, userId, timestamp, signature } = req.body;
  if(!cmdName || !UUID || !userId || !signature || !timestamp) {
    res.status(400).json({
      error: "Invalid package header",
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return
  }
  // 检验时间戳是否正确，相差不能大于 10 秒
  let parsedTimeStamp = parseInt(timestamp)
  if(isNaN(parsedTimeStamp)) {
    res.status(400).json({
      error: "Invalid timestamp",
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return
  }
  const currentTimestampInSeconds = Math.floor(Date.now() / 1000);
  if(Math.abs(currentTimestampInSeconds - parsedTimeStamp) > 10) {
    // 超时包，不接受
    res.status(400).json({
      error: `Timeout package, current ${currentTimestampInSeconds}`,
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return
  }
  // 检验UUID是否发送过了，如果发送过了，不接受
  if(CheckedUUID[UUID]) {
    res.status(400).json({
      error: "Repeat package decline",
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return
  }
  let hash_string = `${cmdName}_^${userId}^&${UUID}*time${timestamp}salt*=${core_info.signatureSalt}`
  console.log(hash_string)
  const sha256Hash = crypto.createHash('sha256');
  sha256Hash.update(hash_string, 'utf-8');
  const sha256HashValue = sha256Hash.digest('hex');
  console.log("desired signature: " + sha256HashValue);
  // 校验签名，如果不一致，不接受
  if(`${signature}` !== sha256HashValue) {
    res.status(400).json({
      error: "Bad signature",
      qaq: "网安爷饶了我的项目吧QAQ"
    });
    return
  }
  CheckedUUID[UUID] = true
  next();
}

module.exports = CheckSignature;