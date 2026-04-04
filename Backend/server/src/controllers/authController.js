const { StatusCodes } = require("http-status-codes");
const { AuthService } = require("../services");
const {OTP}=require('../models');

function buildResponse(success, message, data = {}, error = {}) {
    return { success, message, data, error };
}

async function signUp(req, res) {
    try {
        const data = {
            name: req.body.name,
            email: req.body.email,
            password: req.body.password,
        };
        const { otp } = req.body;

        const latestOtp = await OTP.findOne({ email: data.email }).sort({ createdAt: -1 });

        if (!latestOtp || otp !== latestOtp.otp.toString()) {
            return res.status(StatusCodes.BAD_REQUEST).json(
                buildResponse(false, 'The OTP is not valid or has expired', {}, 'Invalid OTP')
            );
        }

        data.verified = true;
        const authPayload = await AuthService.createUser(data);
        await OTP.deleteMany({ email: data.email });

        return res.status(StatusCodes.CREATED).json(
            buildResponse(true, 'User registered successfully', authPayload, {})
        );
    } catch (err) {
        console.log(err);
        return res.status(err.statusCode || StatusCodes.BAD_REQUEST).json(
            buildResponse(false, err.message || 'Unable to register user', {}, err.message)
        );
    }
}

async function signIn(req,res) {
    try {
        const data={
            email:req.body.email,
            password:req.body.password
        }
        const authPayload = await AuthService.signIn(data);
        return res.status(StatusCodes.OK).json(
            buildResponse(true, 'User logged in successfully', authPayload, {})
        );
    } catch (error) {
        console.log(error);
        return res.status(error.statusCode || StatusCodes.BAD_REQUEST).json(
            buildResponse(false, error.message || 'Invalid credentials', {}, error.message)
        );
    }
}


async function checkAuth(req,res) {
    try {
        const user=req.user;
        if(user){
            return res.status(StatusCodes.OK).json(
                buildResponse(true, 'User authenticated successfully', { user: AuthService.serializeUser(user) }, {})
            );
        }
        return res.status(StatusCodes.BAD_REQUEST).json(
            buildResponse(false, 'User not found', {}, 'User not found')
        );
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(
            buildResponse(false, 'Authentication check failed', {}, error.message)
        );
    }
}



module.exports={
    signUp,
    signIn,
    checkAuth
}
