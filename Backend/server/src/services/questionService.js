const {QuestionRepository} = require('../repositories');
const AppError = require('../utils/errors/appError');
const { StatusCodes } = require('http-status-codes');
const {AuthRepository} = require('../repositories');
const { response } = require('express');
const AuthRepo=new AuthRepository();
const quesRepo=new QuestionRepository();
const {serverConfig}=require('../config');
const { message } = require('../utils/common/errorResponse');

async function nextQues(answer,userId){
    try {
        const user=await AuthRepo.findUserById(userId);
        if(user.currQues===0){
            const response="Level is finished";
            return response;
        }
        console.log('User:',user);
        const isCorrect=await quesRepo.verifyQuestion(user.currQues,answer);
        const plusScore=Number(serverConfig.SCORE);
       console.log(await(quesRepo.lastQues()));
        if(user.currQues===await(quesRepo.lastQues(user.currLvl))){
            const updateUser=await AuthRepo.update(userId,{currQues:0,score:((user.score)+plusScore)});
            const response="Level is finished";
            return response;
        }
        if(isCorrect){
            const newQues=await quesRepo.nextQues(user.currQues,user.currLvl);
            const updateUser=await AuthRepo.update(userId,{currQues:newQues.id,score:((user.score)+plusScore)});
            const hintUsed = Array.isArray(user.hintUsed) ? user.hintUsed.length : 0;
            console.log('updatedUser',updateUser);
            newQues.hint=undefined;
            newQues.answer=undefined;
            const response={
                newQues:newQues,
                score:(updateUser.score+plusScore)-(hintUsed * 10),
                message:"Correct Answer"
            }
            return response;
        }
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST);
    }
}


async function addQues(data) {
    try {
        const lastQues=(await quesRepo.lastQuess()) || 0;
        console.log("lastQues:",lastQues);
        const id=(lastQues)+1;
        data.id=id
        console.log("data",data)
        const response=await quesRepo.create(data);
        console.log("response of add ques:",response);
        return response;
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST);
    }
}


async function currentQues(user) {
    try {
        const query={ lvl: user.currLvl, id: user.currQues };
        if(user.currQues===0){
            const response="Level is finished";
            return response;
        }
        const ques=await quesRepo.getAll(query);
        console.log("Current Quest:",ques);
        ques.hint=undefined;
        ques.answer=undefined;
        const hintUsed = Array.isArray(user.hintUsed) ? user.hintUsed.length : 0;
        ques[0].hint=undefined;
        ques[0].answer=undefined;
        const reponse={
            ques: ques,
            score: (user.score)-(hintUsed * 10),
            message: "Current Question"
        }
        console.log("Current Quest:",reponse);
        return reponse || null;
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST);
    }
}


async function hint(user) {
    try {
        const query={ lvl: user.currLvl, id: user.currQues };
        const response=await quesRepo.getAll(query);
        console.log("Current Quest hint:",response);
        const hintUsed=await AuthRepo.addHintUsed(user._id,response[0]._id);
        console.log(hintUsed);
        const hint =response.length > 0 ? response[0].hint : "No hint available";        
        return hint;
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST);
    }
}


async function getAll() {
    try {
        const reponse=await quesRepo.getAll();
        return reponse;
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST);
    }
}


async function updateQues(id,data) {
    try {
        const reponse=await quesRepo.update(id,data);
        return reponse;
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST); 
    }
}


async function deleteQues(id) {
    try {
        const response=await quesRepo.destroy(id);
        return response;
    } catch (error) {
        console.log(error);
        throw new AppError(error,StatusCodes.BAD_REQUEST);
    }
}


module.exports={nextQues,addQues,currentQues,getAll,updateQues,deleteQues,hint};