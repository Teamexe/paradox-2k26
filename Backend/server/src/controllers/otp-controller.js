const otpGenerator = require('otp-generator');
const {OTP, User} = require('../models');
const {SuccessResponse, ErrorResponse} = require('../utils/common');
const {StatusCodes} = require('http-status-codes');
const sendOTP = async (req, res) => {
  try {
    const { email } = req.body;
    if(!email.endsWith('@nith.ac.in') ){
      ErrorResponse.error = 'Please enter a valid NIT Hamirpur email';
      return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
  }
    // Check if user is already present
    const checkUserPresent = await User.findOne({ email });
    // If user found with provided email
    if (checkUserPresent) {
      ErrorResponse.error = 'User is already registered';
      return res.status(StatusCodes.CONFLICT).json(ErrorResponse);
    }
    let otp = otpGenerator.generate(6, {
      upperCaseAlphabets: false,
      lowerCaseAlphabets: false,
      specialChars: false,
    });
    let result = await OTP.findOne({ otp: otp });
    while (result) {
      otp = otpGenerator.generate(6, {
        upperCaseAlphabets: false,
      });
      result = await OTP.findOne({ otp: otp });
    }
    const otpPayload = { email, otp };
    const otpBody = await OTP.create(otpPayload);
    SuccessResponse.data = "OTP Send Successfully";
    return res.status(StatusCodes.OK).json(SuccessResponse);
  } catch (error) {
    console.log(error.message);
    ErrorResponse.error = error.message;
    return res.status(StatusCodes.INTERNAL_SERVER_ERROR).json(ErrorResponse);
  }
};

module.exports = {sendOTP};