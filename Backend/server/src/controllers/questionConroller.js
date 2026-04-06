const {ErrorResponse,SuccessResponse}=require("../utils/common");
const {StatusCodes}=require('http-status-codes')
const {QuestionService}=require('../services')
const {AppError}=require('../utils/errors/appError');

function createSuccessResponse(message, data = {}) {
    return {
        ...SuccessResponse,
        message,
        data
    };
}

function createErrorResponse(message, error = {}) {
    return {
        ...ErrorResponse,
        message,
        error
    };
}


async function nextQues(req,res) {
    try {
        const answer=req.body.answer?.toLowerCase().trim();
        console.log("Answer:",answer);
        const userId = req.user.id;
        if(!answer){
            return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse('Answer is required'));
        }
        const reponse=await QuestionService.nextQues(answer,userId);
        if(!reponse){
            return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse('Cant get there'));
        }
        return res.status(StatusCodes.OK).json(createSuccessResponse("Next Question fetch Successfully", reponse));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("Something went wrong while getting next question", error));
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
        return res.status(StatusCodes.CREATED).json(createSuccessResponse("Question added successfully", reponse));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("Something went wrong while adding Question", error));
    }
}

async function currentQues(req,res) {
    try {
        const user=req.user;
        console.log(user)
        if(!user){
            return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse('UserId is required'))
        }
        const response=await QuestionService.currentQues(user);
        return res.status(StatusCodes.OK).json(createSuccessResponse("Current Question fetch Successfully", response));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("Something went wrong while fetching Question", error));
    }
}


async function hint(req,res) {
    try {
        const user=req.user;
        console.log(user)
        if(!user){
            return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse('UserId is required'))
        }
        const response=await QuestionService.hint(user);
        return res.status(StatusCodes.OK).json(createSuccessResponse("Hint fetch Successfully", {hint:response}));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("Can't Fetch Hint", error));
    }
}

async function getAll(req,res) {
    try {
        const reponse=await QuestionService.getAll();
        return res.status(StatusCodes.OK).json(createSuccessResponse("Fetched All Questions", reponse));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("Cant fetch all questions", error));
    }
}



async function deleteQues(req,res) {
    try {
        const id=req.params.id;
        const response=await QuestionService.deleteQues(id);
        return res.status(StatusCodes.OK).json(createSuccessResponse("deleted Successfully", response));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("cant delete question", error));
    }
}




async function updateQues(req,res) {
    try {
        const formattedAnswer = typeof req.body?.answer === 'string'
            ? req.body.answer.toLowerCase().trim()
            : req.body?.answer;
        const id=req.params.id;
        const data={
            lvl:req.body?.lvl,
            title:req.body?.title,
            descriptionOrImgUrl:req.body?.descriptionOrImgUrl,
            hint:req.body?.hint,
            answer:formattedAnswer
        }
        console.log("data:",data);
        const reponse=await QuestionService.updateQues(id,data);
        return res.status(StatusCodes.OK).json(createSuccessResponse("Updated Successfully", reponse));
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.BAD_REQUEST).json(createErrorResponse("Cant Update Question", error));
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
