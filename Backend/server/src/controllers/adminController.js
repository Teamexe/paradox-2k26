const {SuccessResponse,ErrorResponse}=require('../utils/common')
const { StatusCodes } = require("http-status-codes");
const { AdminService } = require("../services");


async function signIn(req,res) {
    try {
        const data={
            name:req.body.name,
            password:req.body.password
        }
        const user=await AdminService.signIn(data);
        if(user){
            const token=await AdminService.generateToken(user);
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

async function changeLevel(req,res) {
    try {
        const data={
            Ques:req.body.currQues,
            Lvl:req.body.currLvl,
            TopNumUser:req.body.TopNumUser
        };
        const user=await AdminService.changeLevel(data);
        if(user){
            SuccessResponse.data=user;
            SuccessResponse.message="User level changed successfully";
            return res.status(StatusCodes.OK).json(SuccessResponse);
        }
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}


module.exports={
    signIn,
    changeLevel
}
