//_______________________________________________________________________________________
// REQUIREMENTS AND VARS
var express  = require('express');
var mongoose = require('mongoose');

// for my https app server and http redirect
var https    = require('https');
var http     = require('http');
var fs       = require('fs');

// additionals for my scraping
var request  = require('request');
var cheerio  = require('cheerio');

// for authentication
var passport = require('passport');
var flash = require('connect-flash');
var bcrypt = require('bcrypt-nodejs');
require('./passport')(passport);

// token based authentication
var expressJwt = require('express-jwt');
var jwt = require('jsonwebtoken');
var secret = 'blub-bla-foo-bar';

// beautiful logging
var expressWinston = require('express-winston');
var winston = require('winston');

// TODO
// express-jwt
// coffeescript
// keep it single-app with optional token login ... then able to post todos; to blog like app and system-administration (camera, starting daemons?)
// expose here??????
var app = module.exports = express();


// var db = require('./config/db'); // nope use my todo one
//require('./app/routes')(app); // nope

//_______________________________________________________________________________________
// SET UP EXPRESS APP

// fetching keys with node-fs
var options = {
	// KEYS FOR HTTPS
	// ASYNC WAY FASTER AND JAVASCRIPT STYLE BUT DOESNT WORK HERE
	key:  fs.readFileSync('./certs/privatekey.pem'),
	cert: fs.readFileSync('./certs/certificate.pem'),
	//ca:
	//requestCert: true,
	//rejectUnauthorized: false,
	//passphrase: "mrieger"
	
	// disable CONCURRENT SOCKETS = 5 (eats more cpu and ram though)
	agent: false
};

// compress all req's and res's (above routes and static handlers!)
app.use(express.compress());
app.use(express.static(__dirname + '/public'));
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.set('view.engine', 'ejs');
//app.set('view.engine', 'jade');
//var port = process.env.PORT || 8080;

// authentication:
// cookieParser before session
app.use(express.cookieParser());
app.use(express.session({secret: '@*lCa0s!'}));
app.use(passport.initialize());
app.use(passport.session());
app.use(flash());

// token based ...
app.use('/hiding', expressJwt({secret: secret}));
app.use(express.json());
app.use(express.urlencoded());

//app.use(app.router);

// beautiful logging:
// before routing
//app.use(expressWinston.logger({
//    transports: [
//      new winston.transports.Console({
//        json: true,
//        colorize: true
//      })
//    ]
//}));
app.use(app.router);
// after routing
app.use(expressWinston.errorLogger({
    transports: [
      new winston.transports.Console({
        json: true,
        colorize: true
      })
    ]
}));

var httpPort  = 8080;
var httpsPort = 8081;

//_______________________________________________________________________________________
// MODELS
mongoose.connect('mongodb://localhost:27017/myNode');

var Todo = mongoose.model('Todo', {
	text : String
});


//var User = mongoose.model('User', {
//        post: String,
//        author: {type: String, default: 'Anon'},
//        date: {type: Date, default: Date.now}
//});

// // model and functions for authenticating
// var userSchema = mongoose.Schema({
//     local            : {
//         email        : String,
//         password     : String,
//     },
//    google           : {
//         id           : String,
//         token        : String,
//         email        : String,
//         name         : String
//     }
// });
// userSchema.methods.generateHash = function(password) {
//     return bcrypt.hashSync(password, bcrypt.genSaltSync(8), null);
// };
// userSchema.methods.validPassword = function(password) {
//     return bcrypt.compareSync(password, this.local.password);
// };
// module.exports = mongoose.model('User', userSchema);

//_______________________________________________________________________________________
// ROUTES
// auth routes
require('./routes.js')(app, passport);

//---------------------------------------------------------------------------------------
// API
app.get('/api/todos', function(req, res) {
	Todo.find(function(err, todos) {
		if (err)
			res.send(err)
		res.json(todos);
	});
});

app.post('/api/todos', function(req, res) {
	// create a todo, information comes from AJAX request from Angular
	Todo.create({
		text : req.body.text,
		done : false
	}, function(err, todo) {
		if (err)
			res.send(err);
		Todo.find(function(err, todos) {
			if (err)
				res.send(err)
			res.json(todos);
		});
	});
});

// TODO
// need to comment out before js2coffee -ing the file !!!
// namespace conflict because of coffeescript's delete function
app.delete('/api/todos/:todo_id', function(req, res) {
	Todo.remove({
		_id : req.params.todo_id
	}, function(err, todo) {
		if (err)
			res.send(err);
		Todo.find(function(err, todos) {
			if (err)
				res.send(err)
			res.json(todos);
		});
	});
});

//---------------------------------------------------------------------------------------
// FRONTEND
// express automatically loads file index.html in basedir aka ./public/
app.get('/', function(req, res) {
	res.sendfile('./public/index_animate.html');
});

app.get('/start', function(req, res) {
	res.sendfile('./public/index.html');
});

app.get('/todo', function(req, res) {
	// trying out cookie session manager
	if (req.session.lastPage) {
		//res.write('Last page was: ' + req.session.lastPage + '! ');
		console.log('Last page was: ' + request.pathname + '! ');
	}
	req.session.lastPage = '/todo';
	res.sendfile('./public/index_todo.html');
});

app.get('/animate', function(req, res) {
	res.sendfile('./public/index_animate.html');
});

app.get('/info', function(req, res) {
	console.log(req);
});

app.get('/starter', function(req, res) {
	// trying out cookie session manager
	if (req.session.lastPage) {
		//res.write('Last page was: ' + req.session.lastPage + '! ');
		console.log('Last page was: ' + req.session.lastPage + '! ');
	}
	req.session.lastPage = '/starter';
	res.sendfile('./public/index_starter.html');
});

//---------------------------------------------------------------------------------------
// WEBSCRAPING
// as seen here: http://scotch.io/tutorials/javascript/scraping-the-web-with-node-js
app.get('/scrape', function(req, res){
	url = 'http://www.imdb.com/title/tt1229340/';
	request(url, function(error, response, html){
		if(!error){
			var $ = cheerio.load(html);
			var title, release, rating;
			var json = { title : "", release : "", rating : ""};

			$('.header').filter(function(){
		        	var data = $(this);
		        	title = data.children().first().text();            
       	                	release = data.children().last().children().text();
		        	json.title = title;
	                	json.release = release;
	        	})

            		$('.star-box-giga-star').filter(function(){
	        		var data = $(this);
	        		rating = data.text();
	        		json.rating = rating;
	        	})
		}
        // To write to the system we will use the built in 'fs' library.
        // In this example we will pass 3 parameters to the writeFile function
        // Parameter 1 :  output.json - this is what the created filename will be called
        // Parameter 2 :  JSON.stringify(json, null, 4) - the data to write, here we do an extra step by calling JSON.stringify to make our JSON easier to read
        // Parameter 3 :  callback function - a callback function to let us know the status of our function
        fs.writeFile('output.json', JSON.stringify(json, null, 4), function(err){
        	console.log('File successfully written! - Check your project directory for the output.json file');
        })
        // Finally, we'll just send out a message to the browser reminding you that this app does not have a UI.
        res.send('Check your console!')
	})
})


//---------------------------------------------------------------------------------------
// token based authentication

app.get('/token', function(req, res) {
	res.sendfile('./public/token.html');
});


app.post('/authenticate', function (req, res) {
  //TODO validate req.body.username and req.body.password
  //if is invalid, return 401
  if (!(req.body.username === 'marten' && req.body.password === 'rieger')) {
    res.send(401, 'Wrong user or password');
    return;
  }

  var profile = {
    first_name: 'John',
    last_name: 'Doe',
    email: 'john@doe.com',
    id: 123
  };

  // We are sending the profile inside the token
  var token = jwt.sign(profile, secret, { expiresInMinutes: 60*5 });

  res.json({ token: token });
});

app.get('/hiding/restricted', function (req, res) {
  console.log('user ' + req.user.email + ' is calling /hiding/restricted');
  res.json({
    name: 'foo'
  });
});

//_______________________________________________________________________________________
// START UP APP SERVER
// set up server to listen on httpPort and redirect anyone to https-express-app
var httpProxy = express();
httpProxy.get('*', function(req, res) {
	res.redirect('https://localhost:8081'+req.url);
})
httpProxy.listen(httpPort);

var httpsServer = https.createServer(options,app);
httpsServer.listen(httpsPort);

//app.listen(8070);
console.log("HTTP-Server (Proxy/Redirect) listening on:\t" + httpPort + "\nHTTPS-Server (App) listening on:\t\t" + httpsPort);
exports = module.exports = app;
