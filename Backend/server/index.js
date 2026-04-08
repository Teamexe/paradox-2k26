// Polyfill: SlowBuffer was removed in Node.js v25+
const _buffer = require('buffer');
if (!_buffer.SlowBuffer) {
    _buffer.SlowBuffer = {
        prototype: Buffer.prototype,
    };
}

const dotenv = require('dotenv');
dotenv.config();
const passport = require('passport')
const { serverConfig, dbConfig } = require('./src/config');
const express = require('express');
const app = express();
const cors = require('cors');
const mongoose = require('mongoose');

app.use(cors({
    origin: '*', // Allow all origins for mobile apps
    methods: ['GET', 'POST', 'PATCH', 'PUT', 'DELETE', 'OPTIONS'],
    credentials: false // Credentials are not typically needed for mobile apps
}));
app.options('*', cors());

const session = require('express-session');
app.use(session({
    secret: process.env.SESSION_SECRET || 'your_secret_key', // Replace with a strong secret
    resave: false,
    saveUninitialized: true,
    cookie: { secure: false } // Set `true` if using HTTPS
}));
app.use(passport.initialize());
app.use(passport.session());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

mongoose.connect(dbConfig.MONGODB_URI, dbConfig.MONGOOSE_OPTIONS)
    .then(() => console.log('Connected to MongoDB'))
    .catch(err => {
        console.log("MongoDB not connected", err)
        process.exit(1);
    }

    );

const apiRoutes = require('./src/routes');


app.get('/', (req, res) => {
    res.status(200).send('Sevrer is running.........');
});
app.use('/api', apiRoutes);

const PORT = process.env.PORT || 10000;

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
});