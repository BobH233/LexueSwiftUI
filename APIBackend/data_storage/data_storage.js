const fs = require("fs");
const path = require("path");
const Logger = require("../utils/Logger");
const sqlite3 = require("sqlite3").verbose();
const db = new sqlite3.Database("./server_data/data.db", function () {
  // 创建设备token表
  db.run(`
    CREATE TABLE IF NOT EXISTS RegisteredDevices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      registrationDate DATETIME,
      DeviceToken TEXT,
      Username TEXT
    )
  `);
  // 创建HaoBIT已拉取消息表
  db.run(`
    CREATE TABLE IF NOT EXISTS HaoBITMessage (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      messageHash TEXT,
      updateDate DATETIME,
      jsonStr TEXT
    )
  `);
});


module.exports = {
  getDB: () => db
};
