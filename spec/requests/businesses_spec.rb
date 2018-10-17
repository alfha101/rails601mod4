require 'rails_helper'

RSpec.describe "Businesses", type: :request do
  include_context "db_cleanup_each"
  #originator becomes organizer after creation
  let(:originator) { apply_originator(signup(FactoryGirl.attributes_for(:user)), Business) }

  context "quick API check" do
    let!(:user) { login originator }

    it_should_behave_like "resource index", :business
    it_should_behave_like "show resource", :business
    it_should_behave_like "create resource", :business
    it_should_behave_like "modifiable resource", :business
  end

  shared_examples "cannot create" do |status|
    it "fails to create with #{status}" do
      jpost businesses_path, business_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot update" do |status|
    it "fails to update with #{status}" do
      jput business_path(business_id), business_props
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end
  shared_examples "cannot delete" do |status|
    it "fails to delete with #{status}" do
      jdelete business_path(business_id)
      expect(response).to have_http_status(status)
      expect(parsed_body).to include("errors")
    end
  end

  shared_examples "can create" do |user_roles=[Role::ORGANIZER]|
    it "creates and has user_roles #{user_roles}" do
      jpost businesses_path, business_props
      expect(response).to have_http_status(:created)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id")
      expect(payload).to include("name"=>business_props[:name])
      expect(payload).to include("description"=>business_props[:description])
      expect(payload).to include("notes"=>business_props[:notes])
      expect(payload).to include("user_roles")
      expect(payload["user_roles"]).to include(*user_roles)
    end
    it "reports error for invalid data" do
      jpost businesses_path, business_props.except(:name)
      #pp parsed_body
      #must require :name property -- otherwise get :unprocessable_entity
      #must rescue ActionController::ParameterMissing exception
      #must render :bad_request
      expect(response).to have_http_status(:bad_request)
    end
  end
  shared_examples "can update" do
    it "updates instance" do
      jput business_path(business_id), business_props
      expect(response).to have_http_status(:no_content)
    end
    it "reports update error for invalid data" do
      jput business_path(business_id), business_props.merge(:name=>nil)
      expect(response).to have_http_status(:bad_request)
    end
  end
  shared_examples "can delete" do
    it "deletes instance" do
      jdelete business_path(business_id)
      expect(response).to have_http_status(:no_content)
    end
  end
  shared_examples "field(s) redacted" do
    it "list does not show non-members" do
      jget businesses_path
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload.size).to eq(0)
    end
    it "get does not include notes" do
      jget business_path(business)
      expect(response).to have_http_status(:ok)
      # pp parsed_body
      # byebug
      payload=parsed_body
      expect(payload).to include("id"=>business.id)
      expect(payload).to include("name"=>business.name)
      expect(payload).to include("description")
      expect(payload).to_not include("notes")
      expect(payload).to_not include("user_roles")
    end
  end
  shared_examples "field(s) not redacted" do |user_roles|
    it "list does include notes and user_roles #{user_roles}" do
      jget businesses_path
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload.size).to_not eq(0)
      payload.each do |r|
        expect(r).to include("id")
        expect(r).to include("name")
        expect(r).to include("description")
        expect(r).to include("notes")
        expect(r).to include("user_roles")
        expect(r["user_roles"].to_a).to include(*user_roles)
      end
    end
    it "get does include notes and user_roles #{user_roles}" do
      jget business_path(business)
      expect(response).to have_http_status(:ok)
      #pp parsed_body
      payload=parsed_body
      expect(payload).to include("id"=>business.id)
      expect(payload).to include("name"=>business.name)
      expect(payload).to include("description")
      expect(payload).to include("notes")
      expect(payload).to include("user_roles")
      expect(payload["user_roles"].to_a).to include(*user_roles)
    end
  end

  describe "Business authorization" do
    let(:account)  { signup FactoryGirl.attributes_for(:user) }
    let(:business_props)   { FactoryGirl.attributes_for(:business, :with_fields) }
    let(:business_resources) { 3.times.map { create_resource businesses_path, :business } }
    let(:business_id)   { business_resources[0]["id"] }
    let(:business)      { Business.find(business_id) }
    before(:each) do
      login originator
      business_resources
    end

    context "caller is anonymous" do
      before(:each) do 
        logout
      end
      it_should_behave_like "cannot create", :unauthorized
      it_should_behave_like "cannot update", :unauthorized
      it_should_behave_like "cannot delete", :unauthorized
      it_should_behave_like "field(s) redacted"
    end
    context "caller is authenticated no role" do
      before(:each) do 
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "cannot delete", :forbidden
      it_should_behave_like "field(s) redacted"
    end

    context "caller is member" do
      before(:each) do 
        business_resources.each {|t| apply_member(account,Business.find(t["id"])) }
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "cannot delete", :forbidden
      it_should_behave_like "field(s) not redacted", [Role::MEMBER]
    end

    context "caller is organizer" do
      before(:each) do 
        business_resources.each {|t| apply_organizer(account,Business.find(t["id"])) }
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "can update"
      it_should_behave_like "can delete"
      it_should_behave_like "field(s) not redacted", [Role::ORGANIZER]
    end

    context "caller is originator" do
      it_should_behave_like "can create", [Role::ORGANIZER] #originator becomes orginizer
    end
    context "caller is admin" do
      before(:each) do 
        apply_admin(account)
        login account
      end
      it_should_behave_like "cannot create", :forbidden
      it_should_behave_like "cannot update", :forbidden
      it_should_behave_like "can delete", []
    end
  end
end
