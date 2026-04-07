const {AuthRepository} = require('../repositories');
const AppError = require('../utils/errors/appError');
const jwt = require('jsonwebtoken');
const { StatusCodes } = require('http-status-codes');
const {serverConfig} = require('../config');
const bcrypt = require('bcryptjs');

const authRepo=new AuthRepository();

function normalizeEmail(email) {
    return email.trim().toLowerCase();
}

function serializeUser(user) {
    if (!user) {
        return null;
    }

    const serializedUser = typeof user.toObject === 'function' ? user.toObject() : { ...user };
    delete serializedUser.password;
    return serializedUser;
}

async function createUser(data) {
    try {
        const email = normalizeEmail(data.email);
        const existingUser = await authRepo.findUserByEmail(email);
        if (existingUser) {
            throw new AppError("User already exists", StatusCodes.BAD_REQUEST);
        }

        const user = await authRepo.create({
            ...data,
            email
        });
        const token = await generateToken(user);
        if(!token){
            throw new AppError("Token not generated", StatusCodes.INTERNAL_SERVER_ERROR);
        }

        return {
            user: serializeUser(user),
            token
        };
    } catch (err) {
        throw err;
    }
}

async function signIn(data) {
    try {
        const email = normalizeEmail(data.email);
        const user = await authRepo.findUserByEmail(email);
        if (!user) {
            throw new AppError("Invalid credentials", StatusCodes.BAD_REQUEST);
        }

        const isMatch = await comparePassword(data.password, user.password);
        if (!isMatch) {
            throw new AppError("Invalid credentials", StatusCodes.BAD_REQUEST);
        }

        if (!user.verified) {
            throw new AppError("Please verify your email before signing in", StatusCodes.FORBIDDEN);
        }

        const token = await generateToken(user);
        return {
            user: serializeUser(user),
            token
        };
    } catch (error) {
        if (error instanceof AppError) {
            throw error;
        }

        throw new AppError("Invalid credentials", StatusCodes.BAD_REQUEST);
    }
}
async function findOrCreateUser(profile) {
    try {
        const existingUser = await authRepo.findUserByEmail(profile.emails[0].value);
        if (existingUser) {
            return existingUser;
        }

        const newUser = {
            name: profile.displayName,
            email: profile.emails[0].value,
            googleId: profile.id,
            profilePicture: profile.photos[0].value
        };

        return await authRepo.create(newUser);
    } catch (error) {
        throw new AppError('Error in findOrCreateUser', StatusCodes.INTERNAL_SERVER_ERROR);
    }
}


async function findUserById(id) {
    try {
        const user = await authRepo.findUserById(id);
        if (!user) {
            throw new AppError('User not found', StatusCodes.NOT_FOUND);
        }
        return user;
    } catch (error) {
        throw error;
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
        const user = await authRepo.findUserById(decoded.id);
        if (!user) {
            throw new AppError("User not found", StatusCodes.UNAUTHORIZED);
        }
        return user;
    } catch (err) {
        throw new AppError("Invalid token", StatusCodes.UNAUTHORIZED);
    }
}



module.exports={
    createUser,
    generateToken,
    signIn,
    findUserById,
    findOrCreateUser,
    isAuthentication,
    serializeUser
}
