require 'rails_helper'

RSpec.describe Business, type: :model do
  include_context "db_cleanup_each"

  context "valid business" do
    let(:business) { FactoryGirl.create(:business) }

    it "creates new instance" do
      db_business=Business.find(business.id)
      expect(db_business.name).to eq(business.name)
    end
  end

  context "invalid business" do
    let(:business) { FactoryGirl.build(:business, :name=>nil) }

    it "provides error messages" do
      expect(business.validate).to be false
      expect(business.errors.messages).to include(:name=>["can't be blank"])
    end
  end
end