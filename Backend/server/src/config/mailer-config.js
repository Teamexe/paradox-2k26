const nodemailer = require('nodemailer');
const {ADMIN_EMAIL, ADMIN_EMAIL_PASSWORD} = require('./serverConfig');

const mailSender = nodemailer.createTransport({
    service: 'gmail',
    secure: true,
    port: 465,
    auth: {
        user: ADMIN_EMAIL,
        pass: ADMIN_EMAIL_PASSWORD
    }
});


module.exports = {mailSender};
