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
      Username TEXT,
      FailCount INTEGER
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

const _RegisterDevice = (userId, deviceToken, CB) => {
  db.serialize(() => {
    db.all(
      "SELECT * FROM RegisteredDevices WHERE DeviceToken = ?",
      deviceToken,
      (err, rows) => {
        // 需要确保没有重复注册，如果之前设备id已经注册过了，则更新一下信息
        if(err) {
          CB(err);
          return;
        }
        if(rows.length > 0) {
          // 有重复注册，更新信息
          // console.log(rows)
          db.run('UPDATE RegisteredDevices SET Username = ?, registrationDate = ? WHERE DeviceToken = ?',
          userId, new Date().toISOString(), deviceToken, (updateErr) => {
            CB(updateErr);
            return;
          });
        } else {
          // 新增信息
          db.run('INSERT INTO RegisteredDevices (registrationDate, DeviceToken, Username, FailCount) VALUES (?, ?, ?, ?)', new Date().toISOString(), deviceToken, userId, 0, (err) => {
            CB(err);
            return;
          });
        }
      }
    );
  });
};

const _GetAllRegisteredDevices = (CB) => {
  db.serialize(() => {
    db.all("SELECT * FROM RegisteredDevices", (err, rows) => {
      CB(rows, err);
    })
  })
}

module.exports = {
  getDB: () => db,
  _RegisterDevice,
  _GetAllRegisteredDevices,
};
