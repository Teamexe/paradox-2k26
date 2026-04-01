const { response } = require("express");
const {ErrorResponse,SuccessResponse}=require("../utils/common");
const {StatusCodes}=require('http-status-codes')
const {QuestionService}=require('../services')
const {AppError}=require('../utils/errors/appError');
const { success } = require("../utils/common/errorResponse");


async function nextQues(req,res) {
    try {
        const answer=req.body.answer?.toLowerCase().trim();
        console.log("Answer:",answer);
        const userId = req.user.id;
        if(!answer){
            ErrorResponse.message='Answer is required';
            return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
        }
        const reponse=await QuestionService.nextQues(answer,userId);
        if(!reponse){
            ErrorResponse.message=`Cant get there:${response.message}`;
            return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
        }
        SuccessResponse.message="Next Question fetch Successfully";
        SuccessResponse.data=reponse;
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.message="Something went wrong while getting next question";
        ErrorResponse.error=error;
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}


async function addQues(req,res) {
    try {
        const { lvl, title, descriptionOrImgUrl, hint, answer } = req.body;
        if (!lvl || !answer) {
            throw new AppError("lvl and answer are required", StatusCodes.BAD_REQUEST);
        }
        const formattedAnswer = answer.toLowerCase().trim();
        const data = {
            lvl,
            title,
            descriptionOrImgUrl,
            hint: hint|| "No Hint In This Question",
            answer: formattedAnswer
        };
        console.log("Adding Question data:",data)
        const reponse=await QuestionService.addQues(data);
        return res.status(StatusCodes.ACCEPTED).json(reponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.message="Something went wrong while adding Question"
        ErrorResponse.error=error;
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}

async function currentQues(req,res) {
    try {
        const user=req.user;
        console.log(user)
        if(!user){
            ErrorResponse.message='UserId is required';
            return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse)
        }
        const response=await QuestionService.currentQues(user);
        SuccessResponse.message="Current Question fetch Successfully"
        SuccessResponse.data=response;
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.message="Something went wrong while fetching Question";
        ErrorResponse.error=error;
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}


async function hint(req,res) {
    try {
        const user=req.user;
        console.log(user)
        if(!user){
            ErrorResponse.message='UserId is required';
            return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse)
        }
        const response=await QuestionService.hint(user);
        SuccessResponse.message="Hint fetch Successfully"
        SuccessResponse.data={hint:response};
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        ErrorResponse.message="Can't Fetch Hint";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}

async function getAll(req,res) {
    try {
        const reponse=await QuestionService.getAll();
        SuccessResponse.data=reponse
        SuccessResponse.message="Fetched All Questions";
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        ErrorResponse.message="Cant fetch all questions";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}



async function deleteQues(req,res) {
    try {
        const id=req.params.id;
        const response=await QuestionService.deleteQues(id);
        SuccessResponse.message="deleted Successfully";
        SuccessResponse.data=response;
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        ErrorResponse.message="cant delete question";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}




async function updateQues(req,res) {
    try {
        const id=req.params.id;
        const data={
            lvl:req.body?.lvl,
            title:req.body?.title,
            descriptionOrImgUrl:req.body?.descriptionOrImgUrl,
            hint:req.body?.hint,
            answer:req.body?.answer
        }
        console.log("data:",data);
        const reponse=await QuestionService.updateQues(id,data);
        SuccessResponse.data=reponse;
        SuccessResponse.message="Updated Successfully";
        return res.status(StatusCodes.ACCEPTED).json(SuccessResponse);
    } catch (error) {
        console.log(error);
        ErrorResponse.error=error;
        ErrorResponse.message="Cant Update Question";
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
}


module.exports={
    nextQues,
    addQues,
    currentQues,
    getAll,
    updateQues,
    deleteQues,
    hint
}