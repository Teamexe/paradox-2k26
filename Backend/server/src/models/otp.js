const mongoose = require('mongoose');
const mailSender = require('../utils/common/mailer');

const otpSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true,
  },
  otp: {
    type: String,
    required: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
    expires: 60 * 6, 
  },
});


async function sendVerificationEmail(email, otp) {
  try {
    const mailResponse = await mailSender(
      email,
      "Please verify your email address",
      `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8" />
          <title>Email Verification</title>
        </head>
        <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
          <h2>Email Verification</h2>
          <p>Thank you for signing up in Paradox. Please use the following OTP to verify your email address:</p>
          <p style="font-size: 20px; font-weight: bold;">${otp}</p>
          <p>This OTP is valid for the next 10 minutes.</p>
          <p>If you did not request this, please ignore this email.</p>
          <br />
          <p>Regards,</p>
          <p><strong>Team .exe</strong></p>
        </body>
      </html>
    `
    );
    console.log("Email sent successfully: ", mailResponse);
  } catch (error) {
    console.log("Error occurred while sending email: ", error);
    throw error;
  }
}
otpSchema.pre("save", async function (next) {
  console.log("New document saved to the database");
  // Only send an email when a new document is created
  if (this.isNew) {
    await sendVerificationEmail(this.email, this.otp);
  }
  next();
});
const OTP= mongoose.model("OTP", otpSchema);

module.exports =OTP;