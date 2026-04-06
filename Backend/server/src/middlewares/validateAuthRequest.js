const { StatusCodes } = require('http-status-codes');
const { AuthService } = require('../services');

function buildErrorResponse(message, error) {
    return {
        success: false,
        message,
        data: {},
        error
    };
}

function normalizeEmail(email) {
    return typeof email === 'string' ? email.trim().toLowerCase() : '';
}

function validateEmail(email) {
    const normalizedEmail = normalizeEmail(email);

    if (!normalizedEmail) {
        return 'Email is required';
    }
    if (!normalizedEmail.endsWith('@nith.ac.in') && !normalizedEmail.endsWith('@gmail.com')) {
        return 'Please enter a valid NIT Hamirpur email';
    }

    return null;
}

function validateOtpRequest(req, res, next) {
    const emailError = validateEmail(req.body.email);

    if (emailError) {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse(emailError, emailError));
    }

    req.body.email = normalizeEmail(req.body.email);
    next();
}

function validateSignInRequest(req, res, next) {
    const emailError = validateEmail(req.body.email);

    if (emailError) {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse(emailError, emailError));
    }

    if (!req.body.password || typeof req.body.password !== 'string') {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse('Password is required', 'Password is required'));
    }

    req.body.email = normalizeEmail(req.body.email);
    next();
}

function validateSignUpRequest(req, res, next) {
    const emailError = validateEmail(req.body.email);

    if (emailError) {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse(emailError, emailError));
    }

    if (!req.body.name || typeof req.body.name !== 'string' || !req.body.name.trim()) {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse('Name is required', 'Name is required'));
    }

    if (!req.body.password || typeof req.body.password !== 'string') {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse('Password is required', 'Password is required'));
    }

    if (!req.body.otp || typeof req.body.otp !== 'string') {
        return res.status(StatusCodes.BAD_REQUEST).json(buildErrorResponse('OTP is required', 'OTP is required'));
    }

    req.body.email = normalizeEmail(req.body.email);
    req.body.name = req.body.name.trim();
    req.body.otp = req.body.otp.trim();
    next();
}

async function checkAuth(req, res, next) {
    try {
        const authHeader = req.headers.authorization;

        if (!authHeader) {
            return res.status(StatusCodes.UNAUTHORIZED).json(
                buildErrorResponse('Authorization token is required', 'Authorization token is required')
            );
        }

        const token = authHeader.startsWith('Bearer ')
            ? authHeader.split(' ')[1]
            : authHeader.trim();

        if (!token) {
            return res.status(StatusCodes.UNAUTHORIZED).json(
                buildErrorResponse('Authorization token is required', 'Authorization token is required')
            );
        }

        const user = await AuthService.isAuthentication(token);

        req.user = user;
        next();
    } catch (error) {
        console.log(error);
        return res.status(StatusCodes.UNAUTHORIZED).json(
            buildErrorResponse(error.message || 'Invalid token', error.message || 'Invalid token')
        );
    }
}

module.exports = {
    validateOtpRequest,
    validateSignInRequest,
    validateSignUpRequest,
    checkAuth
};
