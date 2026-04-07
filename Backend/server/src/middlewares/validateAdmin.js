const { StatusCodes } = require('http-status-codes');
const { ErrorResponse } = require('../utils/common');
const AppError = require('../utils/errors/appError');
const  {AdminService}  = require('../services');

function buildErrorResponse(message, error) {
    return {
        success: false,
        message,
        data: {},
        error
    };
}



async function checkAdmin(req,res,next){
    try{
        const authHeader = req.headers.authorization; // Fetch the Authorization header
        // console.log(authHeader)
        if (!authHeader) {
            throw new AppError('No token provided', StatusCodes.UNAUTHORIZED);
        }
        const token = authHeader.startsWith('Bearer ')
            ? authHeader.split(' ')[1]
            : authHeader.trim();
        console.log(token)
        if (!token) {
            throw new AppError('No token provided', StatusCodes.UNAUTHORIZED);
        }
        const response= await AdminService.isAuthentication(token);
        console.log("the response will be in auth....",response);
        if(response){
            req.user=response;
            // console.log(response)
            next()
        }
   }
    catch(error){
        console.log(error)
        return res.status(StatusCodes.UNAUTHORIZED).json(
            buildErrorResponse("You are not authorized to access this resource", error.message || error)
        );
    }
}



  

module.exports=  {checkAdmin}
