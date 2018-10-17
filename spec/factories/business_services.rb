FactoryGirl.define do
  
  factory :business_service do
    creator_id 1

    after(:build) do |link|
      link.service=build(:service) unless link.service
    end 
  end
  
end
