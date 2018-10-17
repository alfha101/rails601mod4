(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .factory("spa-demo.subjects.BusinessesAuthz", BusinessesAuthzFactory);
  
    BusinessesAuthzFactory.$inject = ["spa-demo.authz.Authz",
                                  "spa-demo.authz.BasePolicy"];
    function BusinessesAuthzFactory(Authz, BasePolicy) {
      function BusinessesAuthz() {
        BasePolicy.call(this, "Business");
      }
        //start with base class prototype definitions
      BusinessesAuthz.prototype = Object.create(BasePolicy.prototype);
      BusinessesAuthz.constructor = BusinessesAuthz;
  
  
        //override and add additional methods
      BusinessesAuthz.prototype.canQuery=function() {
        //console.log("BusinessesAuthz.canQuery");
        return Authz.isAuthenticated();
      };
  
        //add custom definitions
      BusinessesAuthz.prototype.canAddService=function(business) {
          return Authz.isOrganizer(business);
      };
      BusinessesAuthz.prototype.canUpdateService=function(business) {
          return Authz.isOrganizer(business)
      };
      BusinessesAuthz.prototype.canRemoveService=function(business) {
          return Authz.isOrganizer(business) || Authz.isAdmin();
      };
      
      return new BusinessesAuthz();
    }
  })();