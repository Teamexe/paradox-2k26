require('dotenv').config();
module.exports = {
    clientID: process.env.GOOGLE_CLIENT_ID ,
    clientSecret: process.env.GOOGLE_CLIENT_SECRET ,
    callbackURL: process.env.CALL_BACK_URL 
}