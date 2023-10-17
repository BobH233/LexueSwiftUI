const express = require("express");

const router = express.Router();

const { addUser } = require("../controllers/AddUser");

router.get("/:id/show", require("../middleware/AntiTimingAtk"), function(req, res){
    res.cookie("hello", "value", {
        httpOnly: true,
    });
    res.cookie("hello2", "value2", {
        httpOnly: false,
    });
    res.send(`show show way! ${req.params.id}`);
});

router.get("/:id/can", function(req, res){
    res.cookie("hello", "value", {
        httpOnly: true,
    });
    res.cookie("hello2", "value2", {
        httpOnly: false,
    });
    res.send(`can can need! ${req.params.id}`);
});

router.get("/add", addUser)

module.exports = router;