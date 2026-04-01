const express=require('express');

const router=express.Router();
const {ValidateAuthReq}=require('../../middlewares');
const { StatusCodes } = require('http-status-codes');
const { success } = require('../../utils/common/errorResponse');
const { SuccessResponse } = require('../../utils/common');



router.get('/home',ValidateAuthReq.checkAuth,async (req,res)=>{
    try {
        const user=req.user;
        
        console.log(user);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        return res.status(StatusCodes.ACCEPTED).json(user);
    } catch (error) {
        console.error('Error fetching user:', error);
        return res.status(StatusCodes.BAD_REQUEST).json({ error: 'Internal server error' });
    }
})



router.get('/currentLevel',ValidateAuthReq.checkAuth,async (req,res)=>{
    try {
        const user=req.user;
        console.log("user:",user);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        const response=user.currLvl;
        SuccessResponse.message="Current Level and Score fetched successfully";
        SuccessResponse.data=response;
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.error('Error fetching user:', error);
        return res.status(StatusCodes.BAD_REQUEST).json({ error: 'Internal server error' });
    }
})



router.get('/score',ValidateAuthReq.checkAuth,async(req,res)=>{
    try {
        const user=req.user;
        console.log("user:",user);
        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }
        const ogScore=user.score;
        const hintUsed = Array.isArray(user.hintUsed) ? user.hintUsed.length : 0;
        const response= ogScore - (hintUsed * 10);
        console.log(ogScore,hintUsed)
        return res.status(StatusCodes.ACCEPTED).json(response);
    } catch (error) {
        console.error('Error fetching user:', error);
        return res.status(StatusCodes.BAD_REQUEST).json({ error: 'Internal server error' });
    }
});


module.exports=router;
