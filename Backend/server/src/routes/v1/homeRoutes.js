const express=require('express');

const router=express.Router();
const {ValidateAuthReq}=require('../../middlewares');
const { StatusCodes } = require('http-status-codes');
const { SuccessResponse } = require('../../utils/common');

function buildResponse(success, message, data = {}, error = {}) {
    return { success, message, data, error };
}

function serializeUser(user) {
    if (!user) {
        return null;
    }

    const serialized = typeof user.toObject === 'function' ? user.toObject() : { ...user };
    delete serialized.password;
    return serialized;
}



router.get('/home',ValidateAuthReq.checkAuth,async (req,res)=>{
    try {
        const user=req.user;
        
        console.log(user);
        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json(buildResponse(false, 'User not found', {}, 'User not found'));
        }
        return res.status(StatusCodes.OK).json(buildResponse(true, 'User fetched successfully', { user: serializeUser(user) }, {}));
    } catch (error) {
        console.error('Error fetching user:', error);
        return res.status(StatusCodes.BAD_REQUEST).json(buildResponse(false, 'Internal server error', {}, error.message));
    }
})



router.get('/currentLevel',ValidateAuthReq.checkAuth,async (req,res)=>{
    try {
        const user=req.user;
        console.log("user:",user);
        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json(buildResponse(false, 'User not found', {}, 'User not found'));
        }
        const response=user.currLvl;
        return res.status(StatusCodes.OK).json(buildResponse(true, 'Current Level and Score fetched successfully', response, {}));
    } catch (error) {
        console.error('Error fetching user:', error);
        return res.status(StatusCodes.BAD_REQUEST).json(buildResponse(false, 'Internal server error', {}, error.message));
    }
})



router.get('/score',ValidateAuthReq.checkAuth,async(req,res)=>{
    try {
        const user=req.user;
        console.log("user:",user);
        if (!user) {
            return res.status(StatusCodes.NOT_FOUND).json(buildResponse(false, 'User not found', {}, 'User not found'));
        }
        const ogScore=user.score;
        const hintUsed = Array.isArray(user.hintUsed) ? user.hintUsed.length : 0;
        const response= ogScore - (hintUsed * 10);
        console.log(ogScore,hintUsed)
        return res.status(StatusCodes.OK).json(buildResponse(true, 'Current score fetched successfully', response, {}));
    } catch (error) {
        console.error('Error fetching user:', error);
        return res.status(StatusCodes.BAD_REQUEST).json(buildResponse(false, 'Internal server error', {}, error.message));
    }
});


module.exports=router;
