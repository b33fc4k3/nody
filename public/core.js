// public/core.js
var scotchTodo = angular.module('scotchTodo', []);

function mainController($scope, $http) {
	$scope.formData = {};

	// when landing on the page, get all todos and show them
	$http.get('/api/todos')
		.success(function(data) {
			$scope.todos = data;
			console.log(data);
		})
		.error(function(data) {
			console.log('Error: ' + data);
		});

	// when submitting the add form, send the text to the node API
	$scope.createTodo = function() {
		$http.post('/api/todos', $scope.formData)
			.success(function(data) {
				$scope.formData = {}; // clear the form so our user is ready to enter another
				$scope.todos = data;
				console.log(data);
			})
			.error(function(data) {
				console.log('Error: ' + data);
			});
	};

	// delete a todo after checking it
	$scope.deleteTodo = function(id) {
		$http.delete('/api/todos/' + id)
			.success(function(data) {
				$scope.todos = data;
				console.log(data);
			})
			.error(function(data) {
				console.log('Error: ' + data);
			});
	};

	// testing angular: http://www.ng-newsletter.com/posts/beginner2expert-data-binding.html
	var updateClock = function() {
    		$scope.clock = new Date();
  	};
  	var timer = setInterval(function() {
    		$scope.$apply(updateClock);
  	}, 1000);
  	updateClock();
}

// // ng-animate and ng-route -ing here ...
// // define our application and pull in ngRoute and ngAnimate
// var animateApp = angular.module('animateApp', ['ngRoute', 'ngAnimate']);
// 
// // ROUTING ===============================================
// // set our routing for this application
// // each route will pull in a different controller
// animateApp.config(function($routeProvider) {
//     $routeProvider
//     	.when('/', {
//     		templateUrl: 'page-home.html',
//             controller: 'mainController'
//     	})
// 
//     	.when('/about', {
//     		templateUrl: 'page-about.html',
//             controller: 'aboutController'
//     	})
// 
//     	.when('/contact', {
//     		templateUrl: 'page-contact.html',
//             controller: 'contactController'
//     	});
// });
// 
// animateApp.controller('mainController', function($scope) {
//     $scope.pageClass = 'page-home';
// });
// 
// animateApp.controller('aboutController', function($scope) {
//     $scope.pageClass = 'page-about';
// });
// 
// animateApp.controller('contactController', function($scope) {
//     $scope.pageClass = 'page-contact';
// });
