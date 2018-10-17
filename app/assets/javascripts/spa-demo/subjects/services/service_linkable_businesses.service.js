(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .factory("spa-demo.subjects.ServiceLinkableBusiness", ServiceLinkableBusiness);
  
    ServiceLinkableBusiness.$inject = ["$resource", "spa-demo.config.APP_CONFIG"];
    function ServiceLinkableBusiness($resource, APP_CONFIG) {
      return $resource(APP_CONFIG.server_url + "/api/services/:service_id/linkable_businesses");
    }
  
  })();