const express = require('express');

const router = express.Router();
const v1Routes = require('./v1');
router.use('/v1',v1Routes);
// router.get('/v1',(req,res)=>{
//     res.status(200).send('Sevrer is running.........');
// });


module.exports = router;