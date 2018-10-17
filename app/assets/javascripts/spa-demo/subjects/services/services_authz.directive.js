(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .directive("sdServicesAuthz", ServicesAuthzDirective);
  
    ServicesAuthzDirective.$inject = [];
  
    function ServicesAuthzDirective() {
      var directive = {
          bindToController: true,
          controller: ServicesAuthzController,
          controllerAs: "vm",
          restrict: "A",
          link: link
      };
      return directive;
  
      function link(scope, element, attrs) {
        console.log("ServicesAuthzDirective", scope);
      }
    }
  
    ServicesAuthzController.$inject = ["$scope",
                                     "spa-demo.subjects.ServicesAuthz"];
    function ServicesAuthzController($scope, ServicesAuthz) {
      var vm = this;
      vm.authz={};
      vm.authz.canUpdateItem = canUpdateItem;
      vm.newItem=newItem;
  
      activate();
      return;
      //////////
      function activate() {
        vm.newItem(null);
      }
  
      function newItem(item) {
        ServicesAuthz.getAuthorizedUser().then(
          function(user){ authzUserItem(item, user); },
          function(user){ authzUserItem(item, user); });
      }
  
      function authzUserItem(item, user) {
        console.log("new Item/Authz", item, user);
  
        vm.authz.authenticated = ServicesAuthz.isAuthenticated();
        vm.authz.canQuery      = ServicesAuthz.canQuery();
        vm.authz.canCreate = ServicesAuthz.canCreate();
        if (item && item.$promise) {
          vm.authz.canUpdate     = false;
          vm.authz.canDelete     = false;
          vm.authz.canGetDetails = false;
          item.$promise.then(function(){ checkAccess(item); });
        } else {
          checkAccess(item)
        }
      }
  
      function checkAccess(item) {
        vm.authz.canUpdate     = ServicesAuthz.canUpdate(item);
        vm.authz.canDelete     = ServicesAuthz.canDelete(item);
        vm.authz.canGetDetails = ServicesAuthz.canGetDetails(item);
        console.log("checkAccess", item, vm.authz);
      }    
  
      function canUpdateItem(item) {
        return ServicesAuthz.canUpdate(item);
      }    
    }
  })();