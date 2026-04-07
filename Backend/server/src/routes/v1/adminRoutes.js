const express =require('express');
const { AdminController } = require('../../controllers');
const { ValidateAdmin } = require('../../middlewares');
const router=express.Router();


router.post('/signIn',AdminController.signIn);
router.post('/changeLevel',ValidateAdmin.checkAdmin,AdminController.changeLevel);

module.exports=router;