require 'rails_helper'

RSpec.describe BusinessService, type: :model do
  include_context "db_cleanup_each"

  context "valid business" do
    let(:business) { FactoryGirl.build(:business) }

    it "build service for business and save" do
      ti = FactoryGirl.build(:business_service, :business=>business)
      ti.save!
      expect(business).to be_persisted
      expect(ti).to be_persisted
      expect(ti.service).to_not be_nil
      expect(ti.service).to be_persisted
    end

    it "relate multiple services" do
      business.business_services << FactoryGirl.build_list(:business_service, 3, :business=>business)
      business.save!
      expect(Business.find(business.id).business_services.size).to eq(3)

      business.business_services.each do |ti|
        expect(ti.service.businesses.first).to eql(business) #same instance
      end
    end

    it "build services using factory" do
      business=FactoryGirl.create(:business, :with_service, :service_count=>2)
      expect(Business.find(business.id).business_services.size).to eq(2)
      business.business_services.each do |ti|
        expect(ti.service.businesses.first).to eql(business) #same instance
      end
    end
  end

  context "related business and service" do
    let(:business) { FactoryGirl.create(:business, :with_service) }
    let(:business_service) { business.business_services.first }
    before(:each) do
      #sanity check that objects and relationships are in place
      expect(BusinessService.where(:id=>business_service.id).exists?).to be true
      expect(Service.where(:id=>business_service.service_id).exists?).to be true
      expect(Business.where(:id=>business_service.business_id).exists?).to be true
    end
    after(:each)  do
      #we always expect the business_service to be deleted during each test
      expect(BusinessService.where(:id=>business_service.id).exists?).to be false
    end

    it "deletes link but not service when business removed" do
      business.destroy
      expect(Service.where(:id=>business_service.service_id).exists?).to be true
      expect(Business.where(:id=>business_service.business_id).exists?).to be false
    end

    it "deletes link but not business when service removed" do
      business_service.service.destroy
      expect(Service.where(:id=>business_service.service_id).exists?).to be false
      expect(Business.where(:id=>business_service.business_id).exists?).to be true
    end
  end
end
