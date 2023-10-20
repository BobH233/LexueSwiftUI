const chalk = require('chalk');
const fs = require('fs');
const path = require("path");

Date.prototype.format = function(fmt) { 
    let o = { 
       "M+" : this.getMonth()+1,                 
       "d+" : this.getDate(),                    
       "h+" : this.getHours(),                   
       "m+" : this.getMinutes(),                 
       "s+" : this.getSeconds(),                 
       "q+" : Math.floor((this.getMonth()+3)/3), 
       "S"  : this.getMilliseconds()             
   }; 
   if(/(y+)/.test(fmt)) {
           fmt=fmt.replace(RegExp.$1, (this.getFullYear()+"").substr(4 - RegExp.$1.length)); 
   }
    for(let k in o) {
       if(new RegExp("("+ k +")").test(fmt)){
            fmt = fmt.replace(RegExp.$1, (RegExp.$1.length==1) ? (o[k]) : (("00"+ o[k]).substr((""+ o[k]).length)));
        }
    }
   return fmt; 
}

const LogFileName = () => {
  return new Date().format("yyyy-MM-dd") + ".txt";
}
const LogErrFileName = () => {
  return new Date().format("yyyy-MM-dd") + "_err.txt";
}

if(!fs.existsSync("logs")){
    fs.mkdirSync("logs");
}

function LogError(str){
    console.log(chalk.redBright("[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Error] ") + str);
    fs.appendFileSync(path.join(__dirname,"../logs/" + LogFileName()), "[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Error] " + str + "\n");
    fs.appendFileSync(path.join(__dirname,"../logs/" + LogErrFileName()), "[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Error] " + str + "\n");
}

function LogInfo(str){
    console.log(chalk.green("[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Info] ") + str);
    fs.appendFileSync(path.join(__dirname,"../logs/" + LogFileName()), "[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Info] " + str + "\n");
}

function LogWarn(str){
    console.log(chalk.yellow("[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Warn] ") + str);
    fs.appendFileSync(path.join(__dirname,"../logs/" + LogFileName()), "[" + new Date().format("yyyy-MM-dd hh:mm:ss") + "][Warn] " + str + "\n");
}

module.exports = { LogInfo,LogWarn,LogError };