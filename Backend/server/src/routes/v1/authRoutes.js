const express =require('express');
const { AuthController } = require('../../controllers');
const {ValidateAuthReq}=require('../../middlewares');
const {otpController}=require('../../controllers');
const router=express.Router();


router.post('/signup',ValidateAuthReq.validateAuthRequest,AuthController.signUp);
router.post('/signup/send-otp',ValidateAuthReq.validateAuthRequest,otpController.sendOTP);
router.post('/signIn',ValidateAuthReq.validateAuthRequest,AuthController.signIn);
router.post('/check',ValidateAuthReq.checkAuth,AuthController.checkAuth);



module.exports=router;




// // const passport = require('passport');
// // const { Strategy: GoogleStrategy } = require('passport-google-oauth20');
// // const {AuthService} = require('../../services');
// // const { SuccessResponse, ErrorResponse } = require('../../utils/common');
// // const { StatusCodes } = require('http-status-codes');
// // const express = require('express');
// // const router = express.Router();
// // const { googleConfig } = require('../../config');

// // passport.use(new GoogleStrategy({
// //     clientID: googleConfig.clientID,
// //     clientSecret: googleConfig.clientSecret,
// //     callbackURL: googleConfig.callbackURL, // Ensure this matches Google console
// // }, async (accessToken, refreshToken, profile, done) => {
// //     try {
// //         const user = await AuthService.findOrCreateUser(profile);
// //         return done(null, user);
// //     } catch (err) {
// //         return done(err, null);
// //     }
// // }));


// // passport.serializeUser((user, done) => {
// //     done(null, user.id);
// // });

// // passport.deserializeUser(async (id, done) => {
// //     try {
// //         const user = await AuthService.findUserById(id);
// //         done(null, user);
// //     } catch (err) {
// //         done(err, null);
// //     }
// // });

// // router.get('/google', passport.authenticate('google', { scope: ['profile', 'email'] }));

// // router.get('/google/callback', passport.authenticate('google', { failureRedirect: '/' }), async (req, res) => {
// //     try {
// //         const token = await AuthService.generateToken(req.user);
// //         SuccessResponse.data = { user: req.user, token };
// //         SuccessResponse.message = 'User authenticated successfully';
// //         return res.status(StatusCodes.OK).json(SuccessResponse);
// //     } catch (error) {
// //         console.error(error);
// //         ErrorResponse.error = error;
// //         return res.status(StatusCodes.BAD_REQUEST).json(ErrorResponse);
// //     }
// // });

// // module.exports = router;




// const express = require("express");
// const { OAuth2Client } = require("google-auth-library");
// // const jwt = require("jsonwebtoken");
// const { AuthService } = require('../../services');
// const { SuccessResponse, ErrorResponse } = require('../../utils/common');
// const { StatusCodes } = require('http-status-codes');
// const { googleConfig } = require('../../config');

// const router = express.Router();
// const client = new OAuth2Client(googleConfig.clientID);

// router.post('/google', async (req, res) => {
//     try {
//         const { idToken } = req.body;
//         const ticket = await client.verifyIdToken({
//             idToken,
//             audience: googleConfig.clientID,
//         });

//         const payload = ticket.getPayload();
//         const user = await AuthService.findOrCreateUser(payload);

//         const token = await AuthService.generateToken(user);

//         SuccessResponse.data = { user, token };
//         SuccessResponse.message = 'User authenticated successfully';
//         return res.status(StatusCodes.OK).json(SuccessResponse);

//     } catch (error) {
//         console.error(error);
//         ErrorResponse.error = error.message;
//         return res.status(StatusCodes.UNAUTHORIZED).json(ErrorResponse);
//     }
// });

// module.exports = router;
