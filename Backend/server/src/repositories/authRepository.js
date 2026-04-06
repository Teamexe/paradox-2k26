const crudRepository = require('./crudRepositories');
const { User } = require('../models');
const AppError = require('../utils/errors/appError');
const { StatusCodes } = require('http-status-codes');

class AuthRepository extends crudRepository {
    constructor() {
        super(User);
    }
    async findUserByEmail(email) {
        try {
            return await this.model.findOne({ email });
        } catch (err) {
            throw new AppError(err.message, StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }
    async findUserById(id) {
        try {
            return await this.model.findById(id);
        } catch (err) {
            throw new AppError(err.message, StatusCodes.INTERNAL_SERVER_ERROR);
        }
    }
    async addHintUsed(userId, questionId) {
        try {
            const updatedUser = await User.findByIdAndUpdate(
                userId,
                { $addToSet: { hintUsed: questionId } },
                { new: true }
            ).populate('hintUsed');
            return updatedUser;
        } catch (error) {
            console.error("Error adding to hintUsed:", error);
            throw error;
        }
    }

    async updateLevel(Ques, Lvl, TopNumUser) {
        try {
            const topUsers = await User.aggregate([
                {
                    $addFields: {
                        hintUsedLength: { $size: { $ifNull: ["$hintUsed", []] } },
                        effectiveScore: {
                            $subtract: [
                                "$score",
                                { $multiply: [{ $size: { $ifNull: ["$hintUsed", []] } }, 10] }
                            ]
                        }
                    }
                },
                { $sort: { effectiveScore: -1 } },
                { $limit: TopNumUser },
                { $project: { _id: 1 } }
            ]);

            const topUserIds = topUsers.map(user => user._id);

            const result = await User.updateMany(
                { _id: { $in: topUserIds } },
                {
                    $set: {
                        currQues: Ques,
                        currLvl: Lvl,
                    }
                }
            );

            console.log(`Updated ${result.modifiedCount} users.`);
            return {
                matchedCount: result.matchedCount,
                modifiedCount: result.modifiedCount,
                currQues: Ques,
                currLvl: Lvl,
                topUserIds
            };
        }
        catch (error) {
            console.error('Error:', error);
            throw error;
        }
    }

}

module.exports = AuthRepository;
