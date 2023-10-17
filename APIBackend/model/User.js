const mongoose = require('mongoose');

const UserSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true
    },
    email: {
        type: String,
        required: true,
        unique: true
    },
    password: {
        type: String,
        required: true
    },
    permissions: {
        type: [{
            name: String,
            isAllowed: Boolean
        }],
        required: false,
        default: {
            name: "defaultPermission",
            isAllowed: true
        }
    }
});

module.exports = mongoose.model("User", UserSchema);