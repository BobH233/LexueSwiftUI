const User = require("../model/User");
const bcrypt = require("bcryptjs");

const addUser = async(req,res,next) => {
    try{
        let { email, password, username } = req.query;
        const salt = bcrypt.genSaltSync(10);
        const hash = bcrypt.hashSync(password, salt);
        const newUser = new User({
            username,
            email,
            password: hash
        });
        await newUser.save();
        res.status(200).json({
            code: 200,
            message: "user create successfully",
        });
    }catch(err){
        next(err);
    }
}

module.exports = { addUser };