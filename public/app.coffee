#______________________________________________________________________________
# animateApp for index_animate.html
animateApp = angular.module("animateApp", [
  "ngRoute"
  "ngAnimate"
])
animateApp.config ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "page-home.html"
    controller: "mainController"
  ).when("/about",
    templateUrl: "page-about.html"
    controller: "aboutController"
  ).when "/contact",
    templateUrl: "page-contact.html"
    controller: "contactController"

  return

animateApp.controller "mainController", ($scope) ->
  $scope.pageClass = "page-home"
  return

animateApp.controller "aboutController", ($scope) ->
  $scope.pageClass = "page-about"
  return

animateApp.controller "contactController", ($scope) ->
  $scope.pageClass = "page-contact"
  return


#______________________________________________________________________________
# controller for my geek nerd page
angular.module("MainCtrl", []).controller "MainController", ($scope) ->
  $scope.tagline = "To the moon and back!"
  return

angular.module("GeekCtrl", []).controller "GeekController", ($scope) ->
  $scope.tagline = "The square root of life is pi!"
  return

angular.module("NerdCtrl", []).controller "NerdController", ($scope) ->
  $scope.tagline = "Nothing beats a pocket protector!"
  return

angular.module("GeekService", []).factory "Geek", [
  "$http"
  ($http) ->
]
angular.module("NerdService", []).factory "Nerd", [
  "$http"
  ($http) ->
]
angular.module("appRoutes", []).config [
  "$routeProvider"
  "$locationProvider"
  ($routeProvider, $locationProvider) ->
    
    # home page
    $routeProvider.when("/",
      templateUrl: "views/home.html"
      controller: "MainController"
    ).when("/nerds",
      templateUrl: "views/nerd.html"
      controller: "NerdController"
    ).when "/geeks",
      templateUrl: "views/geek.html"
      controller: "GeekController"

    $locationProvider.html5Mode true
]
angular.module "sampleApp", [
  "ngRoute"
  "appRoutes"
  "MainCtrl"
  "NerdCtrl"
  "NerdService"
  "GeekCtrl"
  "GeekService"
]
