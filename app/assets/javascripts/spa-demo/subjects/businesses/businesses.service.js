(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .factory("spa-demo.subjects.Business", BusinessFactory);
  
    BusinessFactory.$inject = ["$resource","spa-demo.config.APP_CONFIG"];
    function BusinessFactory($resource, APP_CONFIG) {
      var service = $resource(APP_CONFIG.server_url + "/api/businesses/:id",
          { id: '@id'},
          { update: {method:"PUT"} }
        );
      return service;
    }
  })();