const data_storage = require("../data_storage/data_storage");

const GuardBool = (origin) => {
  if (origin == 0) return false;
  else if(origin == 1) return true;
  else if(origin == "true") return true;
  else if(origin == "false") return false;
  else return false;
}

// 拉取app的通知
const GetAppNotifications = (req, res, next) => {
  try {
    let { lastId } = req.body;
    if(!lastId) {
      lastId = 0
    }
    data_storage._QueryAppNotificationsAfterId(lastId, (result, err) => {
      if(err) {
        next(err);
        return;
      }
      for (let i = 0; i < result.length; i++) {
        result[i].pinned = GuardBool(result[i].pinned)
        result[i].isPopupNotification = GuardBool(result[i].isPopupNotification)
      }
      res.json(result);
    })
  } catch (err) {
    next(err)
  }
}

// admin: 创建新的app通知
const AddNewAppNotifications = (req, res, next) => {
  try {
    let { markdownContent, pinned, isPopupNotification, appVersionLimit } = req.body;
    data_storage._AddAppNotification(markdownContent, pinned, isPopupNotification, appVersionLimit, (err) => {
      if(err) {
        next(err);
        return;
      }
      res.json({
        msg: "添加成功"
      });
    })
  } catch (err) {
    next(err)
  }
}

// admin: 编辑app通知
const EditAppNotifications = (req, res, next) => {
  try {
    let { id, markdownContent, pinned, isPopupNotification, appVersionLimit } = req.body;
    data_storage._EditAppNotification(id, markdownContent, pinned, isPopupNotification, appVersionLimit, (err) => {
      if(err) {
        next(err);
        return;
      }
      res.json({
        msg: "修改成功"
      });
    })
  } catch (err) {
    next(err)
  }
}

// admin: 删除app通知
const DeleteAppNotifications = (req, res, next) => {
  try {
    let { id} = req.body;
    data_storage._DeleteAppNotification(id, (err) => {
      if(err) {
        next(err);
        return;
      }
      res.json({
        msg: "删除成功"
      });
    })
  } catch (err) {
    next(err)
  }
}

module.exports = {
  GetAppNotifications,
  AddNewAppNotifications,
  EditAppNotifications,
  DeleteAppNotifications
}