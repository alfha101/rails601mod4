require 'rails_helper'

RSpec.describe "BusinessServices", type: :request do
  include_context "db_cleanup_each"
  #originator becomes organizer after creation
  let(:originator) { apply_originator(signup(FactoryGirl.attributes_for(:user)), Business) }

  describe "manage business/service relationships" do
    let!(:user) { login originator }
    context "valid business and service" do
      let(:business) { create_resource(businesses_path, :business, :created) }
      let(:service) { create_resource(services_path, :service, :created) }
      let(:business_service_props) { 
        FactoryGirl.attributes_for(:business_service, :service_id=>service["id"]) 
      }

      it "can associate service with business" do
        #associated the Service to the Business
        jpost business_business_services_path(business["id"]), business_service_props
        expect(response).to have_http_status(:no_content)

        #get BusinessServices for Business and verify associated with Service
        jget business_business_services_path(business["id"])
        expect(response).to have_http_status(:ok)
        puts response.body
        payload=parsed_body
        expect(payload.size).to eq(1)
        expect(payload[0]).to include("service_id"=>service["id"])
        expect(payload[0]).to include("service_name"=>service["name"])
      end

      it "must have service" do
        jpost business_business_services_path(business["id"]), 
              business_service_props.except(:service_id)
        expect(response).to have_http_status(:bad_request)
        payload=parsed_body
        expect(payload).to include("errors")
        expect(payload["errors"]["full_messages"]).to include(/param/,/missing/)
      end
    end
  end

  shared_examples "can get links" do
    it "can get links for Business" do
      jget business_business_services_path(linked_business_id)
      # pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(linked_service_ids.count)
      expect(parsed_body[0]).to include("service_name")
      expect(parsed_body[0]).to_not include("business_name")
    end
    it "can get links for Service" do
      jget service_business_services_path(linked_service_id)
      # pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(1)
      expect(parsed_body[0]).to_not include("service_name")
      expect(parsed_body[0]).to include("business_name"=>linked_business["name"])
    end
  end
  shared_examples "get linkables" do |count, user_roles=[]|
    it "return linkable businesses" do
      jget service_linkable_businesses_path(linked_service_ids[0])
      #pp parsed_body
      expect(response).to have_http_status(:ok)
      expect(parsed_body.size).to eq(count)
      if (count > 0)
          parsed_body.each do |business|
            expect(business["id"]).to be_in(unlinked_business_ids)
            expect(business).to include("description")
            expect(business).to include("notes")
            expect(business).to include("user_roles")
            expect(business["user_roles"]).to include(*user_roles)
          end
      end
    end
  end
  shared_examples "can create link" do
    it "link from Business to Service" do
      jpost business_business_services_path(linked_business_id), business_service_props
      expect(response).to have_http_status(:no_content)
      jget business_business_services_path(linked_business_id)
      expect(parsed_body.size).to eq(linked_service_ids.count+1)
    end
    it "link from Service to Business" do
      jpost service_business_services_path(business_service_props[:service_id]), 
                                    business_service_props.merge(:business_id=>linked_business_id)
      expect(response).to have_http_status(:no_content)
      jget business_business_services_path(linked_business_id)
      expect(parsed_body.size).to eq(linked_service_ids.count+1)
    end
    it "bad request when link to unknown Service" do
      jpost business_business_services_path(linked_business_id), 
                                    business_service_props.merge(:service_id=>99999)
      expect(response).to have_http_status(:bad_request)
    end
    it "bad request when link to unknown Business" do
      jpost service_business_services_path(business_service_props[:service_id]), 
                                    business_service_props.merge(:business_id=>99999)
      expect(response).to have_http_status(:bad_request)
    end
  end
  shared_examples "can update link" do
    it do
      jput business_business_service_path(business_service["business_id"], business_service["id"]), 
                             business_service.merge("priority"=>0)
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "can delete link" do
    it do
      jdelete business_business_service_path(business_service["business_id"], business_service["id"])
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "cannot create link" do |status|
    it do
      jpost business_business_services_path(linked_business_id), business_service_props
      expect(response).to have_http_status(status)
    end
  end
  shared_examples "cannot update link" do |status|
    it do
      jput business_business_service_path(business_service["business_id"], business_service["id"]), 
                             business_service.merge("priority"=>0)
      expect(response).to have_http_status(status)
    end
  end
  shared_examples "cannot delete link" do |status|
    it do
      jdelete business_business_service_path(business_service["business_id"], business_service["id"])
      expect(response).to have_http_status(status)
    end
  end


  describe "BusinessService Authn policies" do
    let(:account)         { signup FactoryGirl.attributes_for(:user) }
    let(:business_resources) { 3.times.map { create_resource(businesses_path, :business, :created) } }
    let(:service_resources) { 4.times.map { create_resource(services_path, :service, :created) } }
    let(:businesses)          { business_resources.map {|t| Business.find(t["id"]) } }
    let(:linked_business)    { businesses[0] }
    let(:linked_business_id) { linked_business.id }
    let(:linked_service_ids)  { (0..2).map {|idx| service_resources[idx]["id"] } }
    let(:unlinked_business_ids){ (1..2).map {|idx| business_resources[idx]["id"] } }
    let(:linked_service_id)   { service_resources[0]["id"] }
    let(:orphan_service_id)   { service_resources[3]["id"] }     #unlinked service to link to business
    let(:business_service_props) { { :service_id=>orphan_service_id } } #payload required to link service
    let(:business_service)       { #return existing business so we can modify
      jget business_business_services_path(linked_business_id)
      expect(response).to have_http_status(:ok)
      parsed_body[0]
    }
    before(:each) do
      login originator
      business_resources
      service_resources
      linked_service_ids.each do |service_id| #link business and services, leave orphans
        jpost business_business_services_path(linked_business_id), {:service_id=>service_id}
        expect(response).to have_http_status(:no_content)
      end
    end

    context "user is anonymous" do
      before(:each) { logout }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :unauthorized
      it_should_behave_like "cannot update link", :unauthorized
      it_should_behave_like "cannot delete link", :unauthorized
    end
    context "user is authenticated" do
      before(:each) { login account }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :forbidden
      it_should_behave_like "cannot update link", :forbidden
      it_should_behave_like "cannot delete link", :forbidden
    end
    context "user is member" do
      before(:each) do
        login apply_member(account, businesses) 
      end
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2, [Role::MEMBER]
      it_should_behave_like "can create link"
      it_should_behave_like "cannot update link", :forbidden
      it_should_behave_like "cannot delete link", :forbidden
    end
    context "user is organizer" do
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 2, [Role::ORGANIZER]
      it_should_behave_like "can create link"
      it_should_behave_like "can update link"
      it_should_behave_like "can delete link"
    end
    context "user is admin" do
      before(:each) { login apply_admin(account) }
      it_should_behave_like "can get links"
      it_should_behave_like "get linkables", 0
      it_should_behave_like "cannot create link", :forbidden
      it_should_behave_like "cannot update link", :forbidden
      it_should_behave_like "can delete link"
    end
  end
end
