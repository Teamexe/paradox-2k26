const { mailConfig } = require("../../config");
const { serverConfig } = require("../../config");

const mailSender = async (email, title, body) => {
  try {
    const info = await mailConfig.mailSender.sendMail({
      from: `Team .exe <${serverConfig.ADMIN_EMAIL}>`,
      to: email,
      subject: title,
      html: body,
    });

    console.log("Email info: ", info);
    return info;
  } catch (error) {
    console.log("Mailer error:", error.message);
    throw error;
  }
};

module.exports = mailSender;
