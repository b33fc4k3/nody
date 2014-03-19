# app/routes.js

# =====================================
# HOME PAGE (with login links) ========
# =====================================
# load the index.ejs file

# =====================================
# LOGIN ===============================
# =====================================
# show the login form

# render the page and pass in any flash data if it exists

# process the login form
# app.post('/login', do all our passport stuff here);

# =====================================
# SIGNUP ==============================
# =====================================
# show the signup form

# render the page and pass in any flash data if it exists

# process the signup form
# app.post('/signup', do all our passport stuff here);

# =====================================
# PROFILE SECTION =====================
# =====================================
# we will want this protected so you have to be logged in to visit
# we will use route middleware to verify this (the isLoggedIn function)
# get the user out of session and pass to template

# =====================================
# LOGOUT ==============================
# =====================================

# process the signup form
# redirect to the secure profile section
# redirect back to the signup page if there is an error
# allow flash messages

# process the login form
# redirect to the secure profile section
# redirect back to the signup page if there is an error
# allow flash messages

# route middleware to make sure a user is logged in
isLoggedIn = (req, res, next) ->
  
  # if user is authenticated in the session, carry on 
  return next()  if req.isAuthenticated()
  
  # if they aren't redirect them to the home page
  res.redirect "/"
  return
module.exports = (app, passport) ->
  app.get "/", (req, res) ->
    res.render "index.ejs"
    return

  app.get "/login", (req, res) ->
    res.render "login.ejs",
      message: req.flash("loginMessage")

    return

  app.get "/signup", (req, res) ->
    res.render "signup.ejs",
      message: req.flash("signupMessage")

    return

  app.get "/profile", isLoggedIn, (req, res) ->
    res.render "profile.ejs",
      user: req.user

    return

  app.get "/logout", (req, res) ->
    req.logout()
    res.redirect "/"
    return

  app.post "/signup", passport.authenticate("local-signup",
    successRedirect: "/profile"
    failureRedirect: "/signup"
    failureFlash: true
  )
  app.post "/login", passport.authenticate("local-login",
    successRedirect: "/profile"
    failureRedirect: "/login"
    failureFlash: true
  )
  return
