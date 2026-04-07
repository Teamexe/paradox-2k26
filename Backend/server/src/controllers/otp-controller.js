const otpGenerator = require('otp-generator');
const {OTP, User} = require('../models');
const {StatusCodes} = require('http-status-codes');

function buildResponse(success, message, data = {}, error = {}) {
  return { success, message, data, error };
}

const sendOTP = async (req, res) => {
  try {
    const { email } = req.body;

    const checkUserPresent = await User.findOne({ email });
    if (checkUserPresent) {
      return res.status(StatusCodes.CONFLICT).json(
        buildResponse(false, 'User is already registered', {}, 'User is already registered')
      );
    }

    await OTP.deleteMany({ email });

    let otp = otpGenerator.generate(6, {
      upperCaseAlphabets: false,
      lowerCaseAlphabets: false,
      specialChars: false,
    });

    let result = await OTP.findOne({ otp: otp });

    while (result) {
      otp = otpGenerator.generate(6, {
        upperCaseAlphabets: false,
        lowerCaseAlphabets: false,
        specialChars: false,
      });
      result = await OTP.findOne({ otp: otp });
    }

    await OTP.create({ email, otp });

    return res.status(StatusCodes.OK).json(
      buildResponse(true, 'OTP sent successfully', { email }, {})
    );
  } catch (error) {
    console.log(error.message);
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(
      buildResponse(false, 'Failed to send OTP', {}, error.message)
    );
  }
};

module.exports = {sendOTP};
