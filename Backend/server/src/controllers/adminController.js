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
            name: typeof req.body.name === 'string' ? req.body.name.trim() : req.body.name,
            password: typeof req.body.password === 'string' ? req.body.password.trim() : req.body.password
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
        const currQues = Number(req.body.currQues);
        const currLvl = Number(req.body.currLvl);
        const topNumUser = Number(req.body.TopNumUser);

        if (!Number.isInteger(currQues) || !Number.isInteger(currLvl) || !Number.isInteger(topNumUser) || currQues < 0 || currLvl < 1 || topNumUser < 1) {
            return res.status(StatusCodes.BAD_REQUEST).json(
                buildResponse(false, "currQues, currLvl and TopNumUser must be valid positive numbers", {}, "Invalid change level payload")
            );
        }

        const data={
            Ques: currQues,
            Lvl: currLvl,
            TopNumUser: topNumUser
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
