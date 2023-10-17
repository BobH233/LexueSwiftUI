require("dotenv").config();   //config .env file
const express = require("express");
const Logger = require("./utils/Logger");
const crypto = require("crypto");
const http = require("http");
const cookieParser = require('cookie-parser');
const { default: mongoose } = require("mongoose");

// init express config
const expressPort = process.env.BACKENDPORT || 3000;
const hostname = process.env.DOMAIN || "localhost";
const frontPort = process.env.FRONTPORT || 80;
if(hostname == "localhost"){
    process.env.LOCALDEV = true;
}

// init jwt token
const JwtToken = crypto.randomBytes(64).toString('hex');
process.env.JETTOKEN = JwtToken;
Logger.LogInfo("JwtToken: " + JwtToken);

// connect to mongodb
const mongodb_connect = () => {
    return new Promise((resolve, reject) => {
        mongoose.connect(process.env.MONGODB)
        .then(() => {
            Logger.LogInfo("Successfully connected to MongoDB!");
            resolve();
        })
        .catch((err)=>{
            reject(err);
        })
    });
}

// init express app
const app = express();
app.use(cookieParser());
app.use(require("./middleware/SecurityHeader"));
app.use(require("./middleware/Logger"));
app.use(require("body-parser").urlencoded({ extended: true }));
app.use(express.json());

// set routers
app.use("/api/test", require("./routers/TestRouter"));

// set static routers
app.use(express.static(__dirname + '/static'));

// set default routers
app.use(require("./routers/404Router"));
app.use(require("./routers/ErrorRouter"));

const server = http.createServer(app).listen(expressPort,async()=>{
    await mongodb_connect();
    if(process.env.LOCALDEV){
        Logger.LogInfo(`Starting server_DEV on port ${expressPort}`);
    }else{
        Logger.LogInfo(`Starting server_PROD on port ${expressPort}`);
    }
});
