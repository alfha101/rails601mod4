(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")
      .component("sdBusinessEditor", {
        templateUrl: businessEditorTemplateUrl,
        controller: BusinessEditorController,
        bindings: {
          authz: "<"
        },
        require: {
          businessesAuthz: "^sdBusinessesAuthz"
        }      
      })
      .component("sdBusinessSelector", {
        templateUrl: businessSelectorTemplateUrl,
        controller: BusinessSelectorController,
        bindings: {
          authz: "<"
        }
      })
      ;
  
  
    businessEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
    function businessEditorTemplateUrl(APP_CONFIG) {
      return APP_CONFIG.business_editor_html;
    }    
    businessSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
    function businessSelectorTemplateUrl(APP_CONFIG) {
      return APP_CONFIG.business_selector_html;
    }    
  
    BusinessEditorController.$inject = ["$scope","$q",
                                     "$state","$stateParams",
                                     "spa-demo.authz.Authz",
                                     "spa-demo.subjects.Business",
                                     "spa-demo.subjects.BusinessService"];
    function BusinessEditorController($scope, $q, $state, $stateParams, 
                                   Authz, Business, BusinessService) {
      var vm=this;
      vm.create = create;
      vm.clear  = clear;
      vm.update  = update;
      vm.remove  = remove;
      vm.haveDirtyLinks = haveDirtyLinks;
      vm.updateServiceLinks = updateServiceLinks;
  
      vm.$onInit = function() {
        console.log("BusinessEditorController",$scope);
        $scope.$watch(function(){ return Authz.getAuthorizedUserId(); }, 
                      function(){ 
                        if ($stateParams.id) {
                          reload($stateParams.id); 
                        } else {
                          newResource();
                        }
                      });
      }
  
      return;
      //////////////
      function newResource() {
        vm.item = new Business();
        vm.businessesAuthz.newItem(vm.item);
        return vm.item;
      }
  
      function reload(businessId) {
        var itemId = businessId ? businessId : vm.item.id;      
        console.log("re/loading business", itemId);
        vm.services = BusinessService.query({business_id:itemId});
        vm.item = Business.get({id:itemId});
        vm.businessesAuthz.newItem(vm.item);
        vm.services.$promise.then(
          function(){
            angular.forEach(vm.services, function(ti){
              ti.originalPriority = ti.priority;            
            });                     
          });
        $q.all([vm.item.$promise,vm.services.$promise]).catch(handleError);
      }
      function haveDirtyLinks() {
        for (var i=0; vm.services && i<vm.services.length; i++) {
          var ti=vm.services[i];
          if (ti.toRemove || ti.originalPriority != ti.priority) {
            return true;
          }        
        }
        return false;
      }    
  
      function create() {      
        vm.item.errors = null;
        vm.item.$save().then(
          function(){
            console.log("business created", vm.item);
            $state.go(".",{id:vm.item.id});
          },
          handleError);
      }
  
      function clear() {
        newResource();
        $state.go(".",{id: null});    
      }
  
      function update() {      
        vm.item.errors = null;
        var update=vm.item.$update();
        updateServiceLinks(update);
      }
      function updateServiceLinks(promise) {
        console.log("updating links to services");
        var promises = [];
        if (promise) { promises.push(promise); }
        angular.forEach(vm.services, function(ti){
          if (ti.toRemove) {
            promises.push(ti.$remove());
          } else if (ti.originalPriority != ti.priority) {          
            promises.push(ti.$update());
          }
        });
  
        console.log("waiting for promises", promises);
        $q.all(promises).then(
          function(response){
            console.log("promise.all response", response); 
            //update button will be disabled when not $dirty
            $scope.businessform.$setPristine();
            reload(); 
          }, 
          handleError);    
      }
  
      function remove() {      
        vm.item.$remove().then(
          function(){
            console.log("business.removed", vm.item);
            clear();
          },
          handleError);
      }
  
      function handleError(response) {
        console.log("error", response);
        if (response.data) {
          vm.item["errors"]=response.data.errors;          
        } 
        if (!vm.item.errors) {
          vm.item["errors"]={}
          vm.item["errors"]["full_messages"]=[response]; 
        }      
        $scope.businessform.$setPristine();
      }    
    }
  
    BusinessSelectorController.$inject = ["$scope",
                                       "$stateParams",
                                       "spa-demo.authz.Authz",
                                       "spa-demo.subjects.Business"];
    function BusinessSelectorController($scope, $stateParams, Authz, Business) {
      var vm=this;
  
      vm.$onInit = function() {
        console.log("BusinessSelectorController",$scope);
        $scope.$watch(function(){ return Authz.getAuthorizedUserId(); }, 
                      function(){ 
                        if (!$stateParams.id) {
                          vm.items = Business.query();        
                        }
                      });
      }
      return;
      //////////////
    }
  
  })();
  