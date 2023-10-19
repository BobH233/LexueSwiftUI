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

const _DeleteBatchRegisteredDevices = (deletedList, CB) => {
  if(deletedList.length == 0) {
    CB(null);
    return;
  }
  const deviceTokenValues = deletedList.map(token => `'${token}'`).join(',');
  db.serialize(() => {
    db.run(`DELETE FROM RegisteredDevices WHERE DeviceToken IN (${deviceTokenValues})`, (err) => {
      CB(err);
    });
  })
}

const _ResetBatchDeviceFailedCount = (deviceList, CB) => {
  if(deviceList.length == 0) {
    CB(null);
    return;
  }
  const deviceTokenValues = deviceList.map(token => `'${token}'`).join(',');
  db.serialize(() => {
    db.run(`UPDATE RegisteredDevices SET FailCount = 0 WHERE DeviceToken IN (${deviceTokenValues})`, (err) => {
      CB(err);
    });
  });
}

const _UpdateDeviceFailCount = (deviceToken, failCount, CB) => {
  db.serialize(() => {
    db.run(`UPDATE RegisteredDevices SET FailCount = ? WHERE DeviceToken = ?`, failCount, deviceToken, (err) => {
      CB(err);
    });
  });
}

const _AddHaoBITNotificationIfNew = (hash, curNotification, CB) => {
  db.serialize(() => {
    db.all("SELECT * FROM HaoBITMessage WHERE messageHash = ?",
    hash, (err, rows) => {
      if(err) {
        CB(err)
        return
      }
      
      if(rows.length == 0) {
        // 只有不存在的才添加
        let jsonStr = JSON.stringify(curNotification)
        db.run("INSERT INTO HaoBITMessage (messageHash, updateDate, jsonStr) VALUES (?, ?, ?)", hash, new Date().toISOString(), jsonStr, (err) => {
          CB(err)
          return
        })
      } else {
        CB(null)
      }
    })
  })
}

const _GetLatestHaoBITNotificationHash = (CB) => {
  db.serialize(() => {
    db.get('SELECT messageHash FROM HaoBITMessage WHERE id = (SELECT MAX(id) FROM HaoBITMessage)', (err, row) => {
      if (err) {
        CB(null, err);
      } else {
        const messageHash = row.messageHash;
        CB(messageHash, null)
      }
    });
  });
}

const _QueryHaoBITNotificationByHash = (hash, CB) => {
  db.serialize(() => {
    db.all("SELECT * FROM HaoBITMessage WHERE messageHash = ?",
    hash, (err, rows) => {
      if(err) {
        CB(null, err)
        return
      }
      CB(rows, null);
    })
  })
}

const _QueryHaoBITNotificationsAfterId = (id, CB) => {
  db.serialize(() => {
    db.all('SELECT * FROM HaoBITMessage WHERE id > ?', id, (err, rows) => {
      if (err) {
        CB(null, err)
      } else {
        CB(rows, null)
      }
    });
  });
}

module.exports = {
  getDB: () => db,
  _RegisterDevice,
  _GetAllRegisteredDevices,
  _AddHaoBITNotificationIfNew,
  _DeleteBatchRegisteredDevices,
  _ResetBatchDeviceFailedCount,
  _UpdateDeviceFailCount,
  _GetLatestHaoBITNotificationHash,
  _QueryHaoBITNotificationByHash,
  _QueryHaoBITNotificationsAfterId
};
