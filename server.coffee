# _______________________________________________________________________________________
# TODO

# keeping everything in big single files until i feel at least quite confident :D
# express-jwt
# coffeescript
# keep it single-app with optional token login ... then able to post todos; to blog like app and system-administration (camera, starting daemons?)
# font-awesome ;)
# keeping an eye on mongodb ... so it will never ever crash again (sudo rm /var/lib mongo.lock)

# _______________________________________________________________________________________
# set up

express = require("express")
app = express()
mongoose = require("mongoose")
# setting up my http-proxy to https-app
https = require("https")
http = require("http")

# additionals for my scraping and loading certs
request = require("request")
cheerio = require("cheerio")
fs = require("fs")

httpPort = 8080
httpsPort = 8081

# _______________________________________________________________________________________
# configuration

# https node-fs
#http://www.gettingcirrius.com/2012/06/securing-nodejs-and-express-with-ssl.html !!!!
#http://greengeckodesign.com/blog/2013/06/15/creating-an-ssl-certificate-for-node-dot-js/
#http://www.benjiegillam.com/2012/06/node-dot-js-ssl-certificate-chain/
#http://book.mixu.net/node/ch10.html
#https://gist.github.com/youtalk/3216781
#https://stackoverflow.com/questions/15813677/https-redirection-for-all-routes-node-js-express-security-concerns
#https://stackoverflow.com/questions/7450940/automatic-https-connection-redirect-with-node-js-express
options =
  #key:  fs.readFileSync('key.pem'),
  #cert: fs.readFileSync('cert.pem')
  key: fs.readFileSync("./certs/privatekey.pem")
  cert: fs.readFileSync("./certs/certificate.pem")
  #ca:
  #requestCert: true,
  #rejectUnauthorized: false,
  #passphrase: "mrieger"

#var app = module.exports = express.createServer(options); // ???
#var app = require('express').createServer(options); // ???

#var httpsServer      = express.createServer(options);								// create our app w/ express
#var app      = express.createServer(options); 								// create our app w/ express
mongoose.connect "mongodb://localhost:27017/myNode" # connect to mongoDB database on modulus.io

# starter-node-angular ???
# var db = require('./config/db'); // nope use my todo one
# var port = process.env.PORT || 8080;
#require('./app/routes')(app); // nope
#
# order of configuration is important!!!
# if i put logger before static it will log requests for static files aswell
app.configure ->
  app.use express.logger("dev") # log every request to the console
  app.use express.static(__dirname + "/public") # set the static files location /public/img will be /img for users
  app.use express.favicon(__dirname + "/public/img/favicon_bsd.ico")
  #app.use express.logger("dev") # log every request to the console
  #https://stackoverflow.com/questions/12046421/how-to-configure-express-js-jade-to-process-html-files
  #app.set 'view engine', 'jade'
  #app.set 'views', __dirname + '/views' 
  app.use express.bodyParser() # pull information from html in POST
  app.use express.methodOverride() # simulate DELETE and PUT
  #testweise
  #app.use(express.session( { secret: 'mrieger' } ));
  #app.use(express.cookieParser());
  #app.use(app.router);
  return

#httpsServer.configure(function() {
#	app.use(express.static(__dirname + '/public')); 		// set the static files location /public/img will be /img for users
#	app.use(express.logger('dev')); 						// log every request to the console
#	app.use(express.bodyParser()); 							// pull information from html in POST
#	app.use(express.methodOverride()); 						// simulate DELETE and PUT
#});

# _______________________________________________________________________________________
# models

Todo = mongoose.model("Todo",
  text: String
)
User = mongoose.model("User",
  post: String
  author:
    type: String
    default: "Anon"
  date:
    type: Date
    default: Date.now
)

# _______________________________________________________________________________________
# routes

# api ---------------------------------------------------------------------
# get all todos
app.get "/api/todos", (req, res) ->
  # use mongoose to get all todos in the database
  Todo.find (err, todos) ->
    # if there is an error retrieving, send the error. nothing after res.send(err) will execute
    res.send err  if err
    res.json todos # return all todos in JSON format
    return
  return

# create todo and send back all todos after creation
app.post "/api/todos", (req, res) ->
  # create a todo, information comes from AJAX request from Angular
  Todo.create
    text: req.body.text
    done: false
  , (err, todo) ->
    res.send err  if err
    # get and return all the todos after you create another
    Todo.find (err, todos) ->
      res.send err  if err
      res.json todos
      return
    return
  return

# delete a todo
# ###########################
# delete conflicts with coffeescript namespace!!!
# so i needed to comment out the following before js2coffee -ing it
app.delete "/api/todos/:todo_id", (req, res) ->
  Todo.remove
    _id : req.params.todo_id
  , (err, todo) ->
    res.send err if err
      # get and return all the todos after you create another
    Todo.find (err, todos) ->
      res.send err if err
      res.json todos
      return
    return
  return

# _______________________________________________________________________________________
# frontend routes

# ANGULAR =====================================================================
# express automatically loads file index.html in basedir aka ./public/
app.get "/", (req, res) ->
  res.sendfile "./public/index_animate.html" # load the single view file (angular will handle the page changes on the front-end)
  return

#app.get('/', function(req, res) {
#	res,redirect('https://localhost:8081/public/index.html');
#	//res.sendfile('./public/index.html'); // load the single view file (angular will handle the page changes on the front-end)
#});
app.get "/start", (req, res) ->
  res.sendfile "./public/index.html"
  return

app.get "/todo", (req, res) ->
  res.sendfile "./public/index_todo.html"
  return

app.get "/animate", (req, res) ->
  res.sendfile "./public/index_animate.html"
  return

app.get "/info", (req, res) ->
  console.log req
  return

app.get "/starter", (req, res) ->
  res.sendfile "./public/index_starter.html"
  return

# WEBSCRAPING =================================================================
# as seen here: http://scotch.io/tutorials/javascript/scraping-the-web-with-node-js
app.get "/scrape", (req, res) ->
  url = "http://www.imdb.com/title/tt1229340/"
  request url, (error, response, html) ->
    unless error
      $ = cheerio.load(html)
      title = undefined
      release = undefined
      rating = undefined
      json =
        title: ""
        release: ""
        rating: ""

      $(".header").filter ->
        data = $(this)
        title = data.children().first().text()
        release = data.children().last().children().text()
        json.title = title
        json.release = release
        return

      $(".star-box-giga-star").filter ->
        data = $(this)
        rating = data.text()
        json.rating = rating
        return
    
    # To write to the system we will use the built in 'fs' library.
    # In this example we will pass 3 parameters to the writeFile function
    # Parameter 1 :  output.json - this is what the created filename will be called
    # Parameter 2 :  JSON.stringify(json, null, 4) - the data to write, here we do an extra step by calling JSON.stringify to make our JSON easier to read
    # Parameter 3 :  callback function - a callback function to let us know the status of our function
    fs.writeFile "output.json", JSON.stringify(json, null, 4), (err) ->
      console.log "File successfully written! - Check your project directory for the output.json file"
      return
    
    # Finally, we'll just send out a message to the browser reminding you that this app does not have a UI.
    res.send "Check your console!"
    return
  return


# listen (start app with node server.js) ======================================
#var app = module.exports = express.createServer();
#https.createServer(options, app).listen(8081);
#https.createServer(options, app).listen(80);

#app.listen(8080);

# https node-fs
#var a = https.createServer(options, function (req, res) {
#  res.writeHead(200);
#  res.end("hello world\n");
#}).listen(8000);

#//=======================================================================================
#// set up server to listen on httpPort and redirect anyone to https-express-app
httpProxy = express()
httpProxy.get "*", (req, res) ->
  res.redirect "https://localhost:8081" + req.url
  return

httpProxy.listen httpPort

# // TODO
# // those two together serve node and mongo
# // why does https not serve!??
# var httpProxy = http.createServer(app);
# httpProxy.listen(httpPort);

#//=======================================================================================
#// start up app server
httpsServer = https.createServer(options, app)

#https.createServer(options, function(req, res) {
#	app.handle(req, res);
#}).listen(httpsPort);
httpsServer.listen httpsPort

#//var httpsServer = express();

#=======================================================================================
# shout out to user
#console.log("App listening on port: " + httpPort + "\nHTTPS on: " + httpsPort);
console.log "HTTP-Server (Proxy/Redirect) listening on:\t" + httpPort + "\nHTTPS-Server (App) listening on:\t\t" + httpsPort
app.listen 8070
exports = module.exports = app # expose app

#http.createServer(app).listen(8070);

#http.get('*',function(req,res){  
#    //res.redirect('https://marten.uk.to'+req.url)
#    res.redirect('https://localhost:8081'+req.url)
#})
#http.listen(8080);

# https redirect as seen here:
# http://stackoverflow.com/questions/15813677/https-redirection-for-all-routes-node-js-express-security-concerns
# http://stackoverflow.com/questions/7450940/automatic-https-connection-redirect-with-node-js-express
# http://stackoverflow.com/questions/10697660/force-ssl-with-expressjs-3
# 01. does work ... but https doesnt serve mongo and animate, only static
#var http = express.createServer();
#http.get('*',function(req,res){  
#    //res.redirect('https://marten.uk.to'+req.url)
#    res.redirect('https://localhost:8081'+req.url)
#})
#http.listen(8080);

# 02.
#function requireHTTPS(req, res, next) {
#    if (!req.secure) {
#        //FYI this should work for local development as well
#        return res.redirect('https://' + req.get('host') + req.url);
#    }
#    next();
#}

#app.use(requireHTTPS);
#
#// oder
#app.use(function(req, res, next) {
#  if(!req.secure) {
#    return res.redirect(['https://', req.get('Host'), req.url].join(''));
#  }
#  next();
#});
