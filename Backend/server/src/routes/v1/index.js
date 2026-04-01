const express=require('express');
const router=express.Router();
const authRoutes=require('./authRoutes')
const HomeRoute=require('./homeRoutes')
const QuestionRoute=require('./questionsRoutes')
const AdminRoute=require('./adminRoutes')
const leaderboard=require('./leaderboardRoutes')
const app=express();


app.use('/',HomeRoute)
app.use('/auth', authRoutes);
app.use('/question',QuestionRoute);
app.use('/admin',AdminRoute);
app.use('/rank',leaderboard);
// app.use('/quiz', quizRoutes);
// app.use('/leaderboard', leaderboardRoutes);

module.exports=app;
