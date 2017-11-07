var express = require('express');
var app = express();

app.use('/api', require('./api'));

app.listen(8080);
console.log('API is running on 8080');
