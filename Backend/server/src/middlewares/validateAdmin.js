const { StatusCodes } = require('http-status-codes');
const { ErrorResponse } = require('../utils/common');
const AppError = require('../utils/errors/appError');
const  {AdminService}  = require('../services');




async function checkAdmin(req,res,next){
    try{
        const authHeader = req.headers.authorization; // Fetch the Authorization header
        // console.log(authHeader)
        if (!authHeader) {
            throw new AppError('No token provided', StatusCodes.UNAUTHORIZED);
        }
        const token = authHeader.split(' ')[1]; // Extract the token part after 'Bearer'
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
        ErrorResponse.message="You are not authorized to access this resource";
        ErrorResponse.error=error
        return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
    }
}



  

module.exports=  {checkAdmin}

