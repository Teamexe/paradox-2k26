const { StatusCodes } = require('http-status-codes');
const { ErrorResponse } = require('../utils/common');
const AppError = require('../utils/errors/appError');
const  {AuthService}  = require('../services');

function validateAuthRequest(req, res, next) {
    if(!req.body.email) {
        ErrorResponse.message = 'Something went wrong while authenticating user';
        ErrorResponse.error = new AppError(['Email was not found in the incoming request in the correct form'], StatusCodes.BAD_REQUEST);
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
    if(!req.body.email.endsWith('@nith.ac.in') ){
        ErrorResponse.message = 'Something went wrong while authenticating user';
        ErrorResponse.error=new AppError(['Please enter a valid NIT Hamirpur email'],StatusCodes.BAD_REQUEST);
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
    if(!req.body.password) {
        ErrorResponse.message = 'Something went wrong while authenticating user';
        ErrorResponse.error = new AppError(['password was not found in the incoming request in the correct form'], StatusCodes.BAD_REQUEST);
        return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
    }
    next();
}




async function checkAuth(req,res,next){
    try{
        const authHeader = req.headers.authorization; // Fetch the Authorization header
        // console.log(authHeader)
        if (!authHeader) {
            throw new Error('No Authorization header provided');
        }
        const token = authHeader.split(' ')[1]; // Extract the token part after 'Bearer'
        if (!token) {
            throw new Error('Malformed Authorization header');
        }
        const response= await AuthService.isAuthentication(token);
        console.log("the response will be in auth....",response) 
        if(response){
            req.user=response;
            // console.log(response)
            next()
        }
   }
    catch(error){
        console.log(error)
        return res
        .status(StatusCodes.UNAUTHORIZED)
        .json(error);
    }
}



  

module.exports=  { validateAuthRequest, checkAuth}

