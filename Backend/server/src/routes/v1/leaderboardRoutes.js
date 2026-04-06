const express=require('express')
const router=express.Router();
const {User}=require('../../models')

router.get("/leaderboard-stream", async (req, res) => {
    res.setHeader("Content-Type", "text/event-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.setHeader("Connection", "keep-alive");

    const sendLeaderboard = async () => {
        try {
            const leaderboard = await User.find().limit(100);

            const response = leaderboard.map(user => {
                const hintUsed = Array.isArray(user.hintUsed) ? user.hintUsed.length : 0;
                return {
                    name: user.name,
                    score: user.score - (hintUsed * 10),
                    updatedAt: user.updatedAt
                };
            });

            response.sort((a, b) => {
                if (b.score !== a.score) {
                    return b.score - a.score;
                }

                const aTime = new Date(a.updatedAt).getTime();
                const bTime = new Date(b.updatedAt).getTime();
                if (aTime !== bTime) {
                    return aTime - bTime;
                }

                return a.name.localeCompare(b.name);
            });

            const payload = response.map(({ updatedAt, ...rest }) => rest);
            res.write(`data: ${JSON.stringify(payload)}\n\n`);
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
