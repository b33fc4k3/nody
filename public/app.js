//______________________________________________________________________________
// animateApp for index_animate.html
var animateApp = angular.module('animateApp', ['ngRoute', 'ngAnimate']);

animateApp.config(function($routeProvider) {
    $routeProvider
    	.when('/', {
    		templateUrl: 'page-home.html',
            controller: 'mainController'
    	})
    	.when('/about', {
    		templateUrl: 'page-about.html',
            controller: 'aboutController'
    	})
    	.when('/contact', {
    		templateUrl: 'page-contact.html',
            controller: 'contactController'
    	});

});

animateApp.controller('mainController', function($scope) {
    $scope.pageClass = 'page-home';
});

animateApp.controller('aboutController', function($scope) {
    $scope.pageClass = 'page-about';
});

animateApp.controller('contactController', function($scope) {
    $scope.pageClass = 'page-contact';
});

//______________________________________________________________________________
// controller for my geek nerd page
angular.module('MainCtrl', []).controller('MainController', function($scope) {
	$scope.tagline = 'To the moon and back!';	
});

angular.module('GeekCtrl', []).controller('GeekController', function($scope) {
	$scope.tagline = 'The square root of life is pi!';	
});

angular.module('NerdCtrl', []).controller('NerdController', function($scope) {
	$scope.tagline = 'Nothing beats a pocket protector!';
});

angular.module('GeekService', []).factory('Geek', ['$http', function($http) {
}]);

angular.module('NerdService', []).factory('Nerd', ['$http', function($http) {
}]);


angular.module('appRoutes', []).config(['$routeProvider', '$locationProvider', function($routeProvider, $locationProvider) {
	$routeProvider
		// home page
		.when('/', {
			templateUrl: 'views/home.html',
			controller: 'MainController'
		})
		.when('/nerds', {
			templateUrl: 'views/nerd.html',
			controller: 'NerdController'
		})
		.when('/geeks', {
			templateUrl: 'views/geek.html',
			controller: 'GeekController'	
		});
	$locationProvider.html5Mode(true);
}]);


angular.module('sampleApp', ['ngRoute', 'appRoutes', 'MainCtrl', 'NerdCtrl', 'NerdService', 'GeekCtrl', 'GeekService']);
