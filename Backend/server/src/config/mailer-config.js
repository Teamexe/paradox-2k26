const { Resend } = require('resend');

const apiKey = process.env.RESEND_API_KEY;

const resend = apiKey ? new Resend(apiKey) : null;

module.exports = {
    resend
};
