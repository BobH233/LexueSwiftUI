require("dotenv").config();   //config .env file
const express = require("express");
const Logger = require("./utils/Logger");
const crypto = require("crypto");
const http = require("http");
const cookieParser = require('cookie-parser');
const fs = require('fs');
const data_storage = require("./data_storage/data_storage")
const HaoBIT = require("./utils/HaoBIT")
const AppBackgroundRefresh = require("./utils/AppBackgroundRefresh")

// init express config
const expressPort = process.env.BACKENDPORT || 3000;
const production_mode = process.env.PRODUCTION_MODE || false
if(production_mode == "true" || production_mode == true){
  process.env.LOCALDEV = false;
} else {
  process.env.LOCALDEV = true;
}

// init jwt token
const JwtToken = crypto.randomBytes(64).toString('hex');
process.env.JETTOKEN = JwtToken;
Logger.LogInfo("JwtToken: " + JwtToken);

// init express app
const app = express();
app.use(cookieParser());
app.use(require("./middleware/SecurityHeader"));
app.use(require("./middleware/Logger"));
app.use(require("body-parser").urlencoded({ extended: true }));
app.use(express.json());

const directoryPath = './server_data'; // 存放服务器数据的目录

if (!fs.existsSync(directoryPath)) {
  // 如果目录不存在，创建它
  fs.mkdirSync(directoryPath);
  Logger.LogInfo('server_data 目录已创建');
} else {
  Logger.LogInfo('server_data 目录已经存在');
}

// 后端定时拉取HaoBIT的消息
HaoBIT.SetIntervalForRefresh()
// APP 定时后台刷新拉取消息
AppBackgroundRefresh.SetIntervalForRefresh()

// set routers
app.use("/api/device", require("./routers/DeviceRouter"));
app.use("/api/notice", require("./routers/NoticeRouter"));
app.use("/api/notification", require("./routers/AppNotificationRouter"));

// set static routers
app.use(express.static(__dirname + '/static'));

// set default routers
app.use(require("./routers/404Router"));
app.use(require("./routers/ErrorRouter"));

const server = http.createServer(app).listen(expressPort,async()=>{
    if(JSON.parse(process.env.LOCALDEV) == true){
      Logger.LogInfo(`Starting server_DEV on port ${expressPort}`);
    }else{
      Logger.LogInfo(`Starting server_PROD on port ${expressPort}`);
    }
});
