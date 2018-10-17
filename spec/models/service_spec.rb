require 'rails_helper'

RSpec.describe Service, type: :model do
  include_context "db_cleanup"

  context "build valid service" do
    it "default service created with random name" do
      service=FactoryGirl.build(:service)
      expect(service.creator_id).to_not be_nil
      expect(service.save).to be true
    end

    it "service with User and non-nil name" do
      user=FactoryGirl.create(:user)
      service=FactoryGirl.build(:service, :with_sname, :creator_id=>user.id)
      expect(service.creator_id).to eq(user.id)
      expect(service.name).to_not be_nil
      expect(service.save).to be true      
    end
  end

  context "invalid service" do
    let(:service) { FactoryGirl.build(:service, :name=>nil) }
    
    it "service with explicit nil name " do
      expect(service.validate).to be false
      #byebug

      expect(service.errors.messages).to include(:name=>["can't be blank"])
    end
  end
end
