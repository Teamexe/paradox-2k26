const mongoose=require('mongoose')

const Schema=mongoose.Schema

const quesSchema=new Schema({
    id:{
        type:Number,
        require:true,
        unique:true
    },
    lvl:{
        type:Number,
        require:true
    },
    title:{
        type:String
    },
    descriptionOrImgUrl:{
        type:String,
    },
    hint:{
        type:String,
        default:"No Hint In This Question"
    },
    answer:{
        type:String,
        require:true
    }
},{
    timestamps:true 
})


const Questions=mongoose.model('Questions',quesSchema);

module.exports=Questions;