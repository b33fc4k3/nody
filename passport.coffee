# config/passport.js

# load all the things we need
LocalStrategy = require("passport-local").Strategy

# load up the user model
User = require("./models/user")

# expose this function to our app using module.exports
module.exports = (passport) ->
  
  # =========================================================================
  # passport session setup ==================================================
  # =========================================================================
  # required for persistent login sessions
  # passport needs ability to serialize and unserialize users out of session
  
  # used to serialize the user for the session
  passport.serializeUser (user, done) ->
    done null, user.id
    return

  
  # used to deserialize the user
  passport.deserializeUser (id, done) ->
    User.findById id, (err, user) ->
      done err, user
      return

    return

  
  # =========================================================================
  # LOCAL SIGNUP ============================================================
  # =========================================================================
  # we are using named strategies since we have one for login and one for signup
  # by default, if there was no name, it would just be called 'local'
  passport.use "local-signup", new LocalStrategy(
    
    # by default, local strategy uses username and password, we will override with email
    usernameField: "email"
    passwordField: "password"
    passReqToCallback: true # allows us to pass back the entire request to the callback
  , (req, email, password, done) ->
    
    # asynchronous
    # User.findOne wont fire unless data is sent back
    process.nextTick ->
      
      # find a user whose email is the same as the forms email
      # we are checking to see if the user trying to login already exists
      User.findOne
        "local.email": email
      , (err, user) ->
        
        # if there are any errors, return the error
        return done(err)  if err
        
        # check to see if theres already a user with that email
        if user
          done null, false, req.flash("signupMessage", "That email is already taken.")
        else
          
          # if there is no user with that email
          # create the user
          newUser = new User()
          
          # set the user's local credentials
          newUser.local.email = email
          newUser.local.password = newUser.generateHash(password)
          
          # save the user
          newUser.save (err) ->
            throw err  if err
            done null, newUser

        return

      return

    return
  )
  
  # =========================================================================
  # LOCAL LOGIN =============================================================
  # =========================================================================
  # we are using named strategies since we have one for login and one for signup
  # by default, if there was no name, it would just be called 'local'
  passport.use "local-login", new LocalStrategy(
    
    # by default, local strategy uses username and password, we will override with email
    usernameField: "email"
    passwordField: "password"
    passReqToCallback: true # allows us to pass back the entire request to the callback
  , (req, email, password, done) -> # callback with email and password from our form
    
    # find a user whose email is the same as the forms email
    # we are checking to see if the user trying to login already exists
    User.findOne
      "local.email": email
    , (err, user) ->
      
      # if there are any errors, return the error before anything else
      return done(err)  if err
      
      # if no user is found, return the message
      return done(null, false, req.flash("loginMessage", "No user found."))  unless user # req.flash is the way to set flashdata using connect-flash
      
      # if the user is found but the password is wrong
      return done(null, false, req.flash("loginMessage", "Oops! Wrong password."))  unless user.validPassword(password) # create the loginMessage and save it to session as flashdata
      
      # all is well, return successful user
      done null, user

    return
  )
  return