const { mailConfig } = require("../../config");

const mailSender = async (email, title, body) => {
  try {
    if (!mailConfig.resend) {
      throw new Error("RESEND_API_KEY is not configured");
    }

    const from = process.env.RESEND_FROM_EMAIL;
    if (!from) {
      throw new Error("RESEND_FROM_EMAIL is not configured");
    }

    const { data, error } = await mailConfig.resend.emails.send({
      from,
      to: email,
      subject: title,
      html: body,
    });

    if (error) {
      throw error;
    }

    console.log("Email info: ", data);
    return data;
  } catch (error) {
    console.log("Mailer error:", error.message);
    throw error;
  }
};

module.exports = mailSender;
