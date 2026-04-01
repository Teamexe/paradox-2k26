require('dotenv').config();
module.exports = {
    BACKEND_PORT: process.env.BACKEND_PORT,
    JWT_SECRET_KEY: process.env.JWT_SECRET_KEY,
    JWT_EXPIRE: process.env.JWT_EXPIRE, 
    EXPIRES_IN: process.env.EXPIRES_IN,
    ADMIN_EMAIL:process.env.ADMIN_EMAIL || 'themritunjai@gmail.com',
    ADMIN_EMAIL_PASSWORD:process.env.ADMIN_EMAIL_PASSWORD || 'lexpylnjfpgocxqn',
    SCORE:process.env.SCORE
};
