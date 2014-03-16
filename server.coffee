# _____________________________________________________________________________
express = require("express")
app = express()
mongoose = require("mongoose")
port = process.env.PORT or 8080
database = require("./config/database")

https    = require('https')
http     = require('http')
fs       = require('fs')
# additionals for my scraping
request  = require('request')
cheerio  = require('cheerio')

_ = require('underscore')

httpPort  = 8080
httpsPort = 8081
options = {
	#key:  fs.readFileSync('key.pem'),
	#cert: fs.readFileSync('cert.pem')
	key:  fs.readFileSync('./privatekey.pem'),
	cert: fs.readFileSync('./certificate.pem')
	#ca:
	#requestCert: true,
	#rejectUnauthorized: false,
	#passphrase: "mrieger"
}


mongoose.connect('mongodb://localhost:27017/myNode')

# configuration
#mongoose.connect database.url
app.configure ->
  app.use express.static(__dirname + "/public")
  app.use express.logger("dev")
  app.use express.bodyParser()
  app.use express.methodOverride()
  return

Todo = mongoose.model('Todo', {
	text : String
})
User = mongoose.model('User', {
        post: String,
        author: {type: String, default: 'Anon'},
        date: {type: Date, default: Date.now}
})
 
require("./app/routes.js") app
app.listen port
console.log "App listening on port " + port



# _____________________________________________________________________________
# app set up
express = require("express")
mongoose = require("mongoose")
http = require("http")
path = require("path")
app = express()

port = process.env.PORT or 8080

# externals
routes = require("./routes")
user = require("./routes/user")
database = require("./config/database")

mongoose.connect database.url

# all environments
app.set "port", process.env.PORT or 3000
app.set "views", path.join(__dirname, "views")
app.set "view engine", "jade"
app.use express.favicon()
app.use express.logger("dev")
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use app.router
app.use express.static(path.join(__dirname, "public"))

# development only
app.use express.errorHandler()  if "development" is app.get("env")
app.get "/", routes.index
app.get "/users", user.list
http.createServer(app).listen app.get("port"), ->
  console.log "Express server listening on port " + app.get("port")
  return

