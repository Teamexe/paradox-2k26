const {SuccessResponse,ErrorResponse}=require('../utils/common')
const { StatusCodes } = require("http-status-codes");
const { AuthService } = require("../services");
const {OTP}=require('../models');
const otp = require('../models/otp');

async function signUp(req, res) {
    try {
        const data = {
            name: req.body.name,
            email: req.body.email,
            password: req.body.password,
        };
        const { otp } = req.body;
        
        if (!data.name || !data.email || !data.password || !otp) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                message: "Please enter all the fields",
                statusCode: StatusCodes.BAD_REQUEST
            });
        }

        const responseOtp = await OTP.find({ email: data.email })
                                   .sort({ createdAt: -1 })
                                   .limit(1);

        console.log("responseOtp", responseOtp);
        
        if (responseOtp.length === 0 || otp !== responseOtp[0].otp.toString()) {
            return res.status(StatusCodes.BAD_REQUEST).json({
                message: "The OTP is not valid", 
                statusCode: StatusCodes.BAD_REQUEST
            });
        }

        console.log("email", data.email, "otp", otp);
        
        data.verified = true;
        const user = await AuthService.createUser(data);
        OTP.deleteMany({email:email}).then((result)=>console.log(result));

        
        return res.status(StatusCodes.OK).json({
            data: user,
            message: "User registered successfully",
            statusCode: StatusCodes.OK
        });
        
    } catch (err) {
        console.log(err);
        return res.status(StatusCodes.BAD_REQUEST).json({
            error: err.message,
            statusCode: StatusCodes.BAD_REQUEST
        });
    }
}

async function signIn(req,res) {
    try {
        const data={
            email:req.body.email,
            password:req.body.password
        }
        const user=await AuthService.signIn(data);
        if(user){
            const token=await AuthService.generateToken(user);
            SuccessResponse.data={user,token};
            SuccessResponse.message="User logged in successfully";
            return res.status(StatusCodes.OK).json(SuccessResponse);
        }
        ErrorResponse.message="Invalid credentials";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}


async function checkAuth(req,res) {
    try {
        const user=req.user;
        if(user){
            SuccessResponse.data=user;
            SuccessResponse.message="User authenticated successfully";
            return res.status(StatusCodes.OK).json(SuccessResponse);
        }
        ErrorResponse.message="User not found";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}



module.exports={
    signUp,
    signIn,
    checkAuth
}