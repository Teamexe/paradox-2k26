const nodemailer = require('nodemailer');
const {ADMIN_EMAIL, ADMIN_EMAIL_PASSWORD} = require('./serverConfig');

const mailSender = nodemailer.createTransport({
    host: process.env.SMTP_HOST || 'smtp.gmail.com',
    port: Number(process.env.SMTP_PORT || 465),
    secure: String(process.env.SMTP_SECURE || 'true') === 'true',
    auth: {
        user: ADMIN_EMAIL,
        pass: ADMIN_EMAIL_PASSWORD
    }
});


module.exports = {mailSender};
