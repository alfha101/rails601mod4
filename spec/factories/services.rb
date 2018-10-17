FactoryGirl.define do
  
  factory :service do
    name { Faker::Lorem.sentence(1).chomp(".") }
    creator_id 1

    trait :with_description do
      description { Faker::Lorem.sentence(1).chomp(".") }
    end

    trait :with_roles do
      after(:create) do |service|
        Role.create(:role_name=>Role::ORGANIZER,
                    :mname=>Service.name,
                    :mid=>service.id,
                    :user_id=>service.creator_id)
      end
    end
  end

end
