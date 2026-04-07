const mongoose=require('mongoose');
const bcrypt=require('bcryptjs')
const Schema=mongoose.Schema;

const adminSchema=new Schema({
    name:{
        type:String,
    },
    password:{
        type:String,
    }
},{timestamps:true})


adminSchema.pre('save',async function(next){
    const user=this;
    if(user.isModified('password')){
        user.password=await bcrypt.hash(user.password,10);
    }
    next();
})

const Admin=mongoose.model('Admin',adminSchema);

module.exports=Admin;