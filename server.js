// set up ========================
var express  = require('express');
var app      = express(); 								// create our app w/ express
var mongoose = require('mongoose'); 					// mongoose for mongodb
// https node-fs
var https    = require('https');
//var http     = require('http');
var fs       = require('fs');
// failed to load c++ bson extension ...
// https://stackoverflow.com/questions/21656420/failed-to-load-c-bson-extension
// When you installed the mongoose module by npm, it hasn't build bson module within it's forlder.  see the file 
// 'node_modules/mongoose/node_modules/mongodb/node_modules/bson/ext/index.js 
// bson = require('../build/Release/bson');
// So just change it to
// bson = require('bson');
// and npm install bson

// configuration =================
// TODO
// express-jwt
// coffeescript

// https node-fs
var options = {
	key:  fs.readFileSync('key.pem'),
	cert: fs.readFileSync('cert.pem')
};

mongoose.connect('mongodb://localhost:27017/myNode'); 	// connect to mongoDB database on modulus.io

app.configure(function() {
	app.use(express.static(__dirname + '/public')); 		// set the static files location /public/img will be /img for users
	app.use(express.logger('dev')); 						// log every request to the console
	app.use(express.bodyParser()); 							// pull information from html in POST
	app.use(express.methodOverride()); 						// simulate DELETE and PUT
});

// define model =================
var Todo = mongoose.model('Todo', {
	text : String
});

var User = mongoose.model('User', {
        post: String,
        author: {type: String, default: 'Anon'},
        date: {type: Date, default: Date.now}
});
        

// routes ======================================================================
// api ---------------------------------------------------------------------
// get all todos
app.get('/api/todos', function(req, res) {

	// use mongoose to get all todos in the database
	Todo.find(function(err, todos) {

		// if there is an error retrieving, send the error. nothing after res.send(err) will execute
		if (err)
			res.send(err)

		res.json(todos); // return all todos in JSON format
	});
});

// create todo and send back all todos after creation
app.post('/api/todos', function(req, res) {

	// create a todo, information comes from AJAX request from Angular
	Todo.create({
		text : req.body.text,
		done : false
	}, function(err, todo) {
		if (err)
			res.send(err);

		// get and return all the todos after you create another
		Todo.find(function(err, todos) {
			if (err)
				res.send(err)
			res.json(todos);
		});
	});

});

// delete a todo
app.delete('/api/todos/:todo_id', function(req, res) {
	Todo.remove({
		_id : req.params.todo_id
	}, function(err, todo) {
		if (err)
			res.send(err);

		// get and return all the todos after you create another
		Todo.find(function(err, todos) {
			if (err)
				res.send(err)
			res.json(todos);
		});
	});
});

// ANGULAR =====================================================================
// frontend
// application -------------------------------------------------------------
app.get('*', function(req, res) {
	res.sendfile('./public/index.html'); // load the single view file (angular will handle the page changes on the front-end)
});

// listen (start app with node server.js) ======================================
//var app = module.exports = express.createServer();
https.createServer(options, app).listen(8081);
//app.listen(8080);
console.log("App listening on port 8080");

// https node-fs
//var a = https.createServer(options, function (req, res) {
//  res.writeHead(200);
//  res.end("hello world\n");
//}).listen(8000);
//https.createServer(options, app).listen(8081);
