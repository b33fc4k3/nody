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

