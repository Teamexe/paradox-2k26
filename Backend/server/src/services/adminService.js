const {AdminRepository} = require('../repositories');
const AppError = require('../utils/errors/appError');
const jwt = require('jsonwebtoken');
const { StatusCodes } = require('http-status-codes');
const {serverConfig} = require('../config');
const bcrypt = require('bcryptjs');
const {AuthRepository} = require('../repositories/');
const authRepo=new AuthRepository();

const adminRepo=new AdminRepository();




async function signIn(data) {
    try {
        const Name=data.name;
        // console.log(email);
        const user = await adminRepo.findOneUser({name:Name});
        console.log(user);
        if (!user) {
            throw new AppError("Invalid Credentials", StatusCodes.BAD_REQUEST);
        }
        const isMatch = await comparePassword(data.password, user.password);
        // console.log("hgfh",data.password);
        // console.log("hgfh",isMatch);
        if (!isMatch) {
            throw new AppError("Invalid password", StatusCodes.BAD_REQUEST);
        }
        return user;
    } catch (error) {
        throw new AppError("Invalid credentials", StatusCodes.BAD_REQUEST);
    }
}





async function generateToken(params) {
    try {
        // console.log(serverConfig.JWT_SECRET_KEY);
        const token = jwt.sign({ id: params._id }, serverConfig.JWT_SECRET_KEY, {expiresIn: serverConfig.JWT_EXPIRE});
        return token;
    } catch (err) {
        console.log("error in the create token",err);
        throw err;
    }
}

async function comparePassword(plainPassword, hashedPassword) {
    // console.log(plainPassword,hashedPassword);
    return bcrypt.compare(plainPassword, hashedPassword);
}



async function isAuthentication(token) {
    try {
        const decoded = jwt.verify(token, serverConfig.JWT_SECRET_KEY);
        console.log(decoded);
        
        const user = await adminRepo.findUserById(decoded.id);
        return user;
    } catch (err) {
        throw new AppError("Invalid token", StatusCodes.UNAUTHORIZED);
    }
}



async function changeLevel(data) {
    try {
        const { Ques, Lvl, TopNumUser } = data;
        // console.log(Ques,Lvl,TopNumUser);
        const user = await authRepo.updateLevel(Ques, Lvl, TopNumUser);
        return user;
    } catch (error) {
        throw new AppError("Error updating level", StatusCodes.INTERNAL_SERVER_ERROR);
    }
}




module.exports={
    signIn,
    generateToken,
    comparePassword,
    isAuthentication,
    changeLevel
}