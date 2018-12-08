(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .factory("spa-demo.subjects.ServicesAuthz", ServicesAuthzFactory);
  
    ServicesAuthzFactory.$inject = ["spa-demo.authz.Authz",
                                  "spa-demo.authz.BasePolicy"];
    function ServicesAuthzFactory(Authz, BasePolicy) {
      function ServicesAuthz() {
        BasePolicy.call(this, "Service");
      }
  
        //start with base class prototype definitions
      ServicesAuthz.prototype = Object.create(BasePolicy.prototype);
      ServicesAuthz.constructor = ServicesAuthz;
  
        //override and add additional methods
      ServicesAuthz.prototype.canCreate=function() {
        //console.log("ItemsAuthz.canCreate");
        //return Authz.isAuthenticated();
        return Authz.isOrganizer();
      };
  
      return new ServicesAuthz();
    }
  })();