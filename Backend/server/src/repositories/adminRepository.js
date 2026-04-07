const crudRepository = require('./crudRepositories');
const {Admin} = require('../models');
const AppError = require('../utils/errors/appError');
const { StatusCodes } = require('http-status-codes');

class AdminRepository extends crudRepository {
    constructor() {
        super(Admin);
    }
    async findUserById(id) {
        try {
            return await this.model.findById(id);
        } catch (err) {
            throw new AppError(err.message, StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }   
    async findOneUser(query){
        try {
            return await this.model.findOne(query);
        } catch (err) {
            throw new AppError(err.message, StatusCodes.INTERNAL_SERVER_ERROR);
        }
    } 
}

module.exports = AdminRepository;