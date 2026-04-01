const {StatusCodes}=require('http-status-codes');
const AppError=require('../utils/errors/appError')


class CrudRepository {
    constructor(model){
        this.model=model;
    }
    async create(data){
        try {
            const responce=await this.model.create(data);
            return responce;
        } catch (error) {
            console.log(error);
            if(error.name == 'MongoServerError') throw error;
            throw new AppError(error.message, StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }
    async update(id,data){
        try {
            const responce= await this.model.findByIdAndUpdate(id,data)
            if(!responce){
                throw new AppError('Not able to find the resource',StatusCodes.NOT_FOUND);
            }
            return responce;
        } catch (error) {
            console.log(error);
            
            if(error.name == 'MongoServerError') throw error;
            throw new AppError(
                'Something went wrong while updating resource',
                StatusCodes.INTERNAL_SERVER_ERROR
            );
        }
    }

    async destroy(id){
        try {
            const responce=await this.model.findByIdAndDelete(id);
            if(!responce) {
                throw new AppError(
                    'Not able to find the resource',
                    StatusCodes.NOT_FOUND
                );
            }
            return responce;
        } catch (error) {
            if(error.name == 'MongoServerError') throw error;
            throw new AppError(
                'Something went wrong while deleting resource',
                StatusCodes.INTERNAL_SERVER_ERROR
            );
        }
    }
    async get(id) {
        try {
            const responce = await this.model.findById(id);
            if(!responce) {
                throw new AppError(
                    'Not able to find the resource',
                    StatusCodes.NOT_FOUND
                );
            }
            return responce;
        } catch (error) {
            if(error.name == 'AppError') throw error;
            throw new AppError(
                'Something went wrong while getting resource',
                StatusCodes.INTERNAL_SERVER_ERROR
            );
        }
    }

    async getAll(query={}) {
        try {
            const response = await this.model.find(query).sort({createdAt: -1});
            return response;
        } catch (error) {
            throw new AppError(
                'Something went wrong while getting all resources',
                StatusCodes.INTERNAL_SERVER_ERROR
            );
        }
    }
}

module.exports=CrudRepository;