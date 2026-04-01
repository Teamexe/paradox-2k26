const express=require('express')
const router=express.Router();
const {User}=require('../../models')

router.get("/leaderboard-stream", async (req, res) => {
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    const sendLeaderboard = async () => {
        try {
            const leaderboard = await User.find().sort({ score: -1 , updatedAt:1}).limit(100);
            
            const response = leaderboard.map(user => {
                const hintUsed = Array.isArray(user.hintUsed) ? user.hintUsed.length : 0;
                return {
                    name: user.name,
                    score: user.score - (hintUsed * 10)                          
                };
            });    
            response.sort((a, b) => b.score - a.score);
            res.write(`data: ${JSON.stringify(response)}\n\n`);
        } catch (error) {
            console.error('Error fetching leaderboard:', error);
            res.write('data: {"error": "Failed to fetch leaderboard"}\n\n');
        }
    };

    sendLeaderboard();

    const changeStream = User.watch();

    changeStream.on("change", async (change) => {
        if (change.operationType === "update" || change.operationType === "insert") {
            sendLeaderboard(); 
        }
    });

    req.on("close", () => {
        changeStream.close();
        res.end();
    });
});


module.exports=router;
