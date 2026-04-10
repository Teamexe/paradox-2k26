const crudRepository = require('./crudRepositories');
const {Questions} = require('../models');
const AppError = require('../utils/errors/appError');
const { StatusCodes } = require('http-status-codes');

class QuestionRepository extends crudRepository{
    constructor(){
        super(Questions);
    }
    async verifyQuestion(id,userAnswer) {
        try {
            const question = await Questions.findOne({id:id});
            if (!question){
                throw new AppError("Question not found",StatusCodes.INTERNAL_SERVER_ERROR);
            }
            return question.answer===userAnswer;
        } catch (error) {
            console.log(error);
            throw new AppError("Question not found",StatusCodes.INTERNAL_SERVER_ERROR)
        }
    }
    async nextQues(id,lvl){
        try {
            const nextQuestion = await Questions.findOne({
                id: { $gt: Number(id) },
                lvl: Number(lvl)
            }).sort({ id: 1 });
            return nextQuestion;
        } catch (error) {
            console.log(error);
            throw new AppError("Error while fetching Question",StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }
    async lastQuess(){
        try {
            const lastQuestion = await Questions.findOne().sort({ id: -1 }); 
            if (!lastQuestion) {
                // throw new AppError("No questions found",StatusCodes.INTERNAL_SERVER_ERROR);
                return 0;
            }
            return lastQuestion.id;
        } catch (error) {
            console.log(error);
            throw new AppError("Error while fetching Question last",StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }
    async lastQues(currLvl){
        try {
            const lastQuestion = await Questions.findOne({lvl:currLvl}).sort({ id: -1 }); 
            if (!lastQuestion) {
                // throw new AppError("No questions found",StatusCodes.INTERNAL_SERVER_ERROR);
                return 0;
            }
            return lastQuestion.id;
        } catch (error) {
            console.log(error);
            throw new AppError("Error while fetching Question last",StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }
}


module.exports=QuestionRepository;