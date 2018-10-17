(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .factory("spa-demo.subjects.ServiceBusiness", ServiceBusiness);
  
    ServiceBusiness.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
    function ServiceBusiness($resource, APP_CONFIG) {
      return $resource(APP_CONFIG.server_url + "/api/services/:service_id/business_services");
    }
  
  })();