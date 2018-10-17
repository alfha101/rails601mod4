FactoryGirl.define do

  factory :business do
    name { Faker::Commerce.product_name }
    sequence(:description) {|n| n%5==0 ? nil : Faker::Lorem.paragraphs.join}
    sequence(:notes) {|n| n%5<2 ? nil : Faker::Lorem.paragraphs.join}

    trait :with_service do
      transient do
        service_count 1
      end
      after(:build) do |business, props|
        service.business_services << build_list(:business_service, props.service_count, :business=>business)
      end
    end

    trait :with_fields do
      description { Faker::Lorem.paragraphs.join }
      notes       { Faker::Lorem.paragraphs.join }
    end

    trait :with_roles do
      transient do
        originator_id 1
        member_id nil
      end

      after(:create) do |business, props|
        Role.create(:role_name=>Role::ORGANIZER,
                    :mname=>Business.name,
                    :mid=>business.id,
                    :user_id=>props.originator_id)
        Role.create(:role_name=>Role::MEMBER,
                    :mname=>Business.name,
                    :mid=>business.id,
                    :user_id=>props.member_id)  if props.member_id
      end
    end
  end

end
