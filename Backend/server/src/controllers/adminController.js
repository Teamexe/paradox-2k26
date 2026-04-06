const {SuccessResponse,ErrorResponse}=require('../utils/common')
const { StatusCodes } = require("http-status-codes");
const { AdminService } = require("../services");

function buildResponse(success, message, data = {}, error = {}) {
    return { success, message, data, error };
}

function serializeAdmin(user) {
    if (!user) {
        return null;
    }

    const serialized = typeof user.toObject === 'function' ? user.toObject() : { ...user };
    delete serialized.password;
    return serialized;
}

async function signIn(req,res) {
    try {
        const data={
            name:req.body.name,
            password:req.body.password
        }
        const user=await AdminService.signIn(data);
        if(user){
            const token=await AdminService.generateToken(user);
            return res.status(StatusCodes.OK).json(
                buildResponse(true, "User logged in successfully", { user: serializeAdmin(user), token }, {})
            );
        }
        return res.status(StatusCodes.BAD_REQUEST).json(
            buildResponse(false, "Invalid credentials", {}, "Invalid credentials")
        );
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(
            buildResponse(false, "Invalid credentials", {}, error.message)
        );
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
            return res.status(StatusCodes.OK).json(
                buildResponse(true, "User level changed successfully", user, {})
            );
        }
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(
            buildResponse(false, "Unable to change level", {}, error.message)
        );
    }
}


module.exports={
    signIn,
    changeLevel
}
