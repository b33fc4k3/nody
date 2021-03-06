# load the things we need
mongoose = require("mongoose")
bcrypt = require("bcrypt-nodejs")

# define the schema for our user model
userSchema = mongoose.Schema(
  local:
    email: String
    password: String

  facebook:
    id: String
    token: String
    email: String
    name: String

  twitter:
    id: String
    token: String
    displayName: String
    username: String

  google:
    id: String
    token: String
    email: String
    name: String
)

# generating a hash
userSchema.methods.generateHash = (password) ->
  bcrypt.hashSync password, bcrypt.genSaltSync(8), null


# checking if password is valid
userSchema.methods.validPassword = (password) ->
  bcrypt.compareSync password, @local.password


# create the model for users and expose it to our app
module.exports = mongoose.model("User", userSchema)
