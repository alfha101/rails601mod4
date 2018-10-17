(function() {
    "use strict";
  
    angular
      .module("spa-demo.subjects")

      .component("sdServiceSelector", {
        templateUrl: serviceSelectorTemplateUrl,
        controller: ServiceSelectorController,
        bindings: {
          authz: "<"
        },
      })
      .component("sdServiceEditor", {
        templateUrl: serviceEditorTemplateUrl,
        controller: ServiceEditorController,
        bindings: {
          authz: "<"
        },
        require: {
          servicesAuthz: "^sdServicesAuthz"
        }
      })
      ;
  
  
    serviceSelectorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
    function serviceSelectorTemplateUrl(APP_CONFIG) {
      return APP_CONFIG.service_selector_html;
    }    
    
    serviceEditorTemplateUrl.$inject = ["spa-demo.config.APP_CONFIG"];
    function serviceEditorTemplateUrl(APP_CONFIG) {
      return APP_CONFIG.service_editor_html;
    }    
  
    ServiceSelectorController.$inject = ["$scope",
                                       "$stateParams",
                                       "spa-demo.authz.Authz",
                                       "spa-demo.subjects.Service"];
    function ServiceSelectorController($scope, $stateParams, Authz, Service) {
      var vm=this;
  
      vm.$onInit = function() {
        console.log("ServiceSelectorController",$scope);
        $scope.$watch(function(){ return Authz.getAuthorizedUserId(); }, 
                      function(){ 
                        if (!$stateParams.id) { 
                          vm.items = Service.query(); 
                        }
                      });
      }
      return;
      //////////////
    }
  
  
    ServiceEditorController.$inject = ["$scope","$q",
                                     "$state", "$stateParams",
                                     "spa-demo.authz.Authz",          
                                     "spa-demo.subjects.Service",
                                     "spa-demo.subjects.ServiceBusiness",
                                     "spa-demo.subjects.ServiceLinkableBusiness",
                                     ];
    function ServiceEditorController($scope, $q, $state, $stateParams, 
                                   Authz, Service, ServiceBusiness,ServiceLinkableBusiness) {
      var vm=this;
      vm.selected_linkables=[];
      vm.create = create;
      vm.clear  = clear;
      vm.update  = update;
      vm.remove  = remove;
      vm.linkBusinesses = linkBusinesses;
  
      vm.$onInit = function() {
        console.log("ServiceEditorController",$scope);
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
        console.log("newResource()");
        vm.item = new Service();
        vm.servicesAuthz.newItem(vm.item);
        return vm.item;
      }
  
      function reload(serviceId) {
        var itemId = serviceId ? serviceId : vm.item.id;
        console.log("re/loading service", itemId);
        vm.item = Service.get({id:itemId});
        vm.businesses = ServiceBusiness.query({service_id:itemId});
        vm.linkable_businesses = ServiceLinkableBusiness.query({service_id:itemId});
        vm.servicesAuthz.newItem(vm.item);
        $q.all([vm.item.$promise,
                vm.businesses.$promise]).catch(handleError);
      }
  
      function clear() {
        newResource();
        $state.go(".", {id:null});
      }
  
      function create() {
        vm.item.errors = null;
        vm.item.$save().then(
          function(){
             console.log("service created", vm.item);
             $state.go(".", {id: vm.item.id}); 
          },
          handleError);
      }
  
      function update() {
        vm.item.errors = null;
        var update=vm.item.$update();
        linkBusinesses(update);
      }
  
      function linkBusinesses(parentPromise) {
        var promises=[];
        if (parentPromise) { promises.push(parentPromise); }
        angular.forEach(vm.selected_linkables, function(linkable){
          var resource=ServiceBusiness.save({service_id:vm.item.id}, {business_id:linkable});
          promises.push(resource.$promise);
        });
  
        vm.selected_linkables=[];
        console.log("waiting for promises", promises);
        $q.all(promises).then(
          function(response){
            console.log("promise.all response", response); 
            $scope.serviceform.$setPristine();
            reload(); 
          },
          handleError);    
      }
  
      function remove() {
        vm.item.errors = null;
        vm.item.$delete().then(
          function(){ 
            console.log("remove complete", vm.item);          
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
        $scope.serviceform.$setPristine();
      }    
    }
  
  })();