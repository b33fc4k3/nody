# public/core.js
mainController = ($scope, $http) ->
  $scope.formData = {}
  
  # when landing on the page, get all todos and show them
  $http.get("/api/todos").success((data) ->
    $scope.todos = data
    console.log data
    return
  ).error (data) ->
    console.log "Error: " + data
    return

  
  # when submitting the add form, send the text to the node API
  $scope.createTodo = ->
    # clear the form so our user is ready to enter another
    $http.post("/api/todos", $scope.formData).success((data) ->
      $scope.formData = {}
      $scope.todos = data
      console.log data
      return
    ).error (data) ->
      console.log "Error: " + data
      return

    return

  
  # delete a todo after checking it
  $scope.deleteTodo = (id) ->
    $http.blub("/api/todos/" + id).success((data) ->
      $scope.todos = data
      console.log data
      return
    ).error (data) ->
      console.log "Error: " + data
      return

    return

  
  # testing angular: http://www.ng-newsletter.com/posts/beginner2expert-data-binding.html
  dateOptions =
    weekday: "long"
    year: "numeric"
    month: "short"
    day: "numeric"
    hour: "2-digit"
    minute: "2-digit"
    second: "2-digit"

  updateClock = ->
    
    #$scope.clock = new Date();
    clock = new Date()
    $scope.clock = clock.toLocaleDateString("de", dateOptions)
    return

  timer = setInterval(->
    $scope.$apply updateClock
    return
  , 1000)
  updateClock()
  return
scotchTodo = angular.module("scotchTodo", [])

# // ng-animate and ng-route -ing here ...
# // define our application and pull in ngRoute and ngAnimate
# var animateApp = angular.module('animateApp', ['ngRoute', 'ngAnimate']);
# 
# // ROUTING ===============================================
# // set our routing for this application
# // each route will pull in a different controller
# animateApp.config(function($routeProvider) {
#     $routeProvider
#     	.when('/', {
#     		templateUrl: 'page-home.html',
#             controller: 'mainController'
#     	})
# 
#     	.when('/about', {
#     		templateUrl: 'page-about.html',
#             controller: 'aboutController'
#     	})
# 
#     	.when('/contact', {
#     		templateUrl: 'page-contact.html',
#             controller: 'contactController'
#     	});
# });
# 
# animateApp.controller('mainController', function($scope) {
#     $scope.pageClass = 'page-home';
# });
# 
# animateApp.controller('aboutController', function($scope) {
#     $scope.pageClass = 'page-about';
# });
# 
# animateApp.controller('contactController', function($scope) {
#     $scope.pageClass = 'page-contact';
# });
