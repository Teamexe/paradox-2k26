const express=require('express');
const router=express.Router();
const {QuestionConroller}=require('../../controllers')
const {ValidateAuthReq}=require('../../middlewares');
const {ValidateAdmin}=require('../../middlewares');



router.patch('/next',ValidateAuthReq.checkAuth,QuestionConroller.nextQues);
router.get('/current',ValidateAuthReq.checkAuth,QuestionConroller.currentQues);
router.get('/hint',ValidateAuthReq.checkAuth,QuestionConroller.hint);
router.post('/add',ValidateAdmin.checkAdmin,QuestionConroller.addQues);
router.get('/getAll',ValidateAdmin.checkAdmin,QuestionConroller.getAll);
router.delete('/delete/:id',ValidateAdmin.checkAdmin,QuestionConroller.deleteQues);
router.patch('/update/:id',ValidateAdmin.checkAdmin,QuestionConroller.updateQues);



module.exports=router;