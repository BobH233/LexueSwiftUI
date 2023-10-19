const axios = require('axios').default;
const Logger = require("../utils/Logger");
const crypto = require('crypto');
const data_storage = require("../data_storage/data_storage");

const url = "https://haobit.top/dev/site/notices.json"

const axiosInstance = axios.create({
  headers: {
    'Cache-Control': 'no-cache', // 禁用缓存
    'Pragma': 'no-cache',
  }
})


const CalcHash = (notification) => {
  let link = notification["link"] ?? ""
  let title = notification['title'] ?? ""
  let source = notification['source'] ?? ""
  let hash_string = `${link}_${title}_${source}`
  const sha256Hash = crypto.createHash('sha256');
  sha256Hash.update(hash_string, 'utf-8');
  return sha256Hash.digest('hex');
}

const RefreshNotification = async() => {
  try {
    const jsonData = (await axiosInstance.get(url)).data;
    for(let i=0;i<jsonData.length; i++) {
      let curNotification = jsonData[i];
      let curHash = CalcHash(curNotification);
      data_storage._AddHaoBITNotificationIfNew(curHash, curNotification, (err)=>{
        if(err) {
          console.log("error:", err);
        }
      })
    }
  } catch (err){
    Logger.LogError(`刷新HaoBIT遇到错误, ${err.message}`)
  }
}

const SetIntervalForRefresh = () => {
  Logger.LogInfo("设定自动刷新HaoBIT定时器...")
  RefreshNotification()
  setInterval(()=> {
    RefreshNotification()
  }, 10 * 60 * 1000); // 十分钟刷新一次HaoBIT
}

module.exports = {
  SetIntervalForRefresh,
}