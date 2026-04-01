const User=require('./authModel');
const Questions=require('./questionModel')
const Admin=require('./adminAuthModel')
const OTP=require('./otp')

module.exports={
    User,
    Questions,
    Admin,
    OTP
}