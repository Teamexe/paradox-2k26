const mongoose=require('mongoose');
const bcrypt=require('bcryptjs')


const Schema=mongoose.Schema
const userSchema= new Schema({
    name:{
        type:String,
        require:true
    },
    email:{
        type:String,
        require:true
    },
    password: {
        type: String,
        required: true,
    },
    googleId: {
        type: String,
        unique: true,
        sparse: true // Allows null values while ensuring uniqueness
    },
    verified: {
        type: Boolean,
        default: false
    },
    profilePicture: {
        type: String
    },
    score:{
        type:Number,
        default: 0
    },
    currQues:{
        type:Number,
        default:1
    },
    currLvl:{
        type:Number,
        default:1
    },
    hintUsed: [{
        type: Schema.Types.ObjectId,
        ref: 'Questions'
    }]
},{
    timestamps:true
})


userSchema.pre('save',async function(next){
    const user=this;
    if(user.isModified('password')){
        user.password=await bcrypt.hash(user.password,10);
    }
    next();
})


const User=mongoose.model('User',userSchema);
module.exports=User;