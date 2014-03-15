// set up ========================
var express  = require('express');
var app      = express(); 								// create our app w/ express
var mongoose = require('mongoose'); 					// mongoose for mongodb
// https node-fs ... all part of node, no need to npm install but fs aka node-fs is to be downloaded
var https    = require('https');
var http     = require('http');
var fs       = require('fs');

var httpPort  = 8080;
var httpsPort = 8081;

// configuration =================
// TODO
// express-jwt
// coffeescript

// https node-fs
//http://www.gettingcirrius.com/2012/06/securing-nodejs-and-express-with-ssl.html !!!!
//http://greengeckodesign.com/blog/2013/06/15/creating-an-ssl-certificate-for-node-dot-js/
//http://www.benjiegillam.com/2012/06/node-dot-js-ssl-certificate-chain/
var options = {
	//key:  fs.readFileSync('key.pem'),
	//cert: fs.readFileSync('cert.pem')
	key:  fs.readFileSync('./privatekey.pem'),
	cert: fs.readFileSync('./certificate.pem')
	//ca:
	//requestCert: true,
	//rejectUnauthorized: false,
	//passphrase: "mrieger"
};

//var app = module.exports = express.createServer(options); // ???
//var app = require('express').createServer(options); // ???

//var httpsServer      = express.createServer(options);								// create our app w/ express
//var app      = express.createServer(options); 								// create our app w/ express
mongoose.connect('mongodb://localhost:27017/myNode'); 	// connect to mongoDB database on modulus.io

app.configure(function() {
	app.use(express.static(__dirname + '/public')); 		// set the static files location /public/img will be /img for users
	app.use(express.logger('dev')); 						// log every request to the console
	app.use(express.bodyParser()); 							// pull information from html in POST
	app.use(express.methodOverride()); 						// simulate DELETE and PUT
	//testweise
	//app.use(express.session( { secret: 'mrieger' } ));
	//app.use(express.cookieParser());
	//app.use(app.router);
});

//httpsServer.configure(function() {
//	app.use(express.static(__dirname + '/public')); 		// set the static files location /public/img will be /img for users
//	app.use(express.logger('dev')); 						// log every request to the console
//	app.use(express.bodyParser()); 							// pull information from html in POST
//	app.use(express.methodOverride()); 						// simulate DELETE and PUT
//});


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
app.get('/', function(req, res) {
	res.sendfile('./public/index.html'); // load the single view file (angular will handle the page changes on the front-end)
});

//app.get('/', function(req, res) {
//	res,redirect('https://localhost:8081/public/index.html');
//	//res.sendfile('./public/index.html'); // load the single view file (angular will handle the page changes on the front-end)
//});


app.get('/animate', function(req, res) {
	res.sendfile('./public/index_animate.html');
});

app.get('/info', function(req, res) {
	console.log(req);
});

// listen (start app with node server.js) ======================================
//var app = module.exports = express.createServer();
//https.createServer(options, app).listen(8081);
//https.createServer(options, app).listen(80);

//app.listen(8080);

// https node-fs
//var a = https.createServer(options, function (req, res) {
//  res.writeHead(200);
//  res.end("hello world\n");
//}).listen(8000);

////=======================================================================================
//// set up server to listen on httpPort and redirect anyone to https-express-app
var httpProxy = express();
httpProxy.get('*', function(req, res) {
	res.redirect('https://localhost:8081'+req.url);
})
httpProxy.listen(httpPort);

// // TODO
// // those two together serve node and mongo
// // why does https not serve!??
// var httpProxy = http.createServer(app);
// httpProxy.listen(httpPort);


////=======================================================================================
//// start up app server
var httpsServer = https.createServer(options,app);
//https.createServer(options, function(req, res) {
//	app.handle(req, res);
//}).listen(httpsPort);
httpsServer.listen(httpsPort);
////var httpsServer = express();

//=======================================================================================
// shout out to user
console.log("App listening on port: " + httpPort + "\nHTTPS on: " + httpsPort);

app.listen(8070);

exports = module.exports = app; 						// expose app

//http.createServer(app).listen(8070);

//http.get('*',function(req,res){  
//    //res.redirect('https://marten.uk.to'+req.url)
//    res.redirect('https://localhost:8081'+req.url)
//})
//http.listen(8080);

// https redirect as seen here:
// http://stackoverflow.com/questions/15813677/https-redirection-for-all-routes-node-js-express-security-concerns
// http://stackoverflow.com/questions/7450940/automatic-https-connection-redirect-with-node-js-express
// http://stackoverflow.com/questions/10697660/force-ssl-with-expressjs-3
// 01. does work ... but https doesnt serve mongo and animate, only static
//var http = express.createServer();
//http.get('*',function(req,res){  
//    //res.redirect('https://marten.uk.to'+req.url)
//    res.redirect('https://localhost:8081'+req.url)
//})
//http.listen(8080);

// 02.
//function requireHTTPS(req, res, next) {
//    if (!req.secure) {
//        //FYI this should work for local development as well
//        return res.redirect('https://' + req.get('host') + req.url);
//    }
//    next();
//}

//app.use(requireHTTPS);
//
//// oder
//app.use(function(req, res, next) {
//  if(!req.secure) {
//    return res.redirect(['https://', req.get('Host'), req.url].join(''));
//  }
//  next();
//});
