// Express
var express = require('express');
var router = express.Router();

// Body Parser
var bodyParser = require('body-parser');

// Get DB variables
var fs = require('fs');
var dbVars = fs.readFileSync('db_vars.json');

// Database
var mysql = require('mysql');
var db = mysql.createConnection(JSON.parse(dbVars));
/*
{
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'clocoss',
}
*/

// Create the initial database if it doesn't exist
try {
    db.query("CREATE TABLE IF NOT EXISTS register (id VARCHAR(50) PRIMARY KEY, count INTEGER)");
} catch (err) {}

// Routes

// Gets the count based on an ID
router.get('/:id', (req, res) => {
    db.query(`SELECT count FROM register WHERE id='${req.params.id}'`, (err, result) => {
        if (err) {
            console.log(err);
            res.sendStatus(500);
            return;
        }
        var returnVal = result.length == 0 ? '0' : (result[0].count).toString();
        console.log(`GET /api/${req.params.id} => ${returnVal}`);
        res.send(returnVal);
    });
});

// Creates (or updates if already exists) a register by adding :count to the existing count
router.post('/:id', bodyParser.text(), (req, res) => {
    var count = req.body ? parseInt(req.body) : 0;
    db.query(`INSERT INTO register (id, count) VALUES ('${req.params.id}', ${count}) ON DUPLICATE KEY UPDATE count=count+${count}`, (err, result) => {
        if (err) {
            console.log(err);
            res.sendStatus(500);
            return;
        }
        db.query(`SELECT count FROM register WHERE id='${req.params.id}'`, (err, result) => {
            var returnVal = (result[0].count).toString();
            console.log(`POST /api/${req.params.id} => ${returnVal}`);
            res.send(returnVal);
        });
    });
});

// Resets the register's value to :count or 0 if :count isn't specified
router.put('/:id', bodyParser.text(), (req, res) => {
    var count = req.body ? parseInt(req.body) : 0;
    db.query(`INSERT INTO register (id, count) VALUES ('${req.params.id}', ${count}) ON DUPLICATE KEY UPDATE count=${count}`, (err, result) => {
        if (err) {
            console.log(err);
            res.sendStatus(500);
        }
        var returnVal = count.toString();
        console.log(`PUT /api/${req.params.id} => ${returnVal}`);
        res.send(returnVal);
    });
});

// Deletes entry with id of :id
router.delete('/:id', (req, res) => {
    db.query(`DELETE FROM register WHERE id='${req.params.id}'`, (err, result) => {
        if (err) {
            console.log(err);
            res.sendStatus(500);
        }
        console.log(`DELETE /api/${req.params.id} => OK`);
        res.sendStatus(204);
    });
});

module.exports = router;
