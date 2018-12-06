namespace :business do
  MEMBERS=["mike","carol","alice","greg","marsha","peter","jan","bobby","cindy", "sam"]
  ADMINS=["mike","carol"]
  ORIGINATORS=["carol","alice"]
  BOYS=["greg","peter","bobby"]
  GIRLS=["marsha","jan","cindy"]

  def user_name first_name
    last_name = (first_name=="alice") ? "nelson" : "brady"
    case first_name
    when "alice"
      last_name = "nelson"
    when "sam"
      last_name = "franklin"
    else
      last_name = "brady"
    end
    "#{first_name} #{last_name}".titleize
  end
  def user_email first_name
    "#{first_name}@bbunch.org"
  end
  def get_user first_name
    User.find_by(:email=>user_email(first_name))
  end

  def users first_names
    first_names.map {|fn| get_user(fn) }
  end
  def first_names users
    users.map {|user| user.email.chomp("@bbunch.org") }
  end
  def admin_users
     @admin_users ||= users(ADMINS)
  end
  def originator_users
     @originator_users ||= users(ORIGINATORS)
  end
  def member_users
     @member_users ||= users(MEMBERS)
  end
  def boy_users
    @boy_users ||= users(BOYS)
  end
  def girl_users
    @girl_users ||= users(GIRLS)
  end
  def mike_user
    @mike_user ||= get_user("mike")
  end

  def create_service  organizer, srv
    puts "building service for #{srv[:name]}, by #{organizer.name}"
    service=Service.create(:creator_id=>organizer.id,:name=>srv[:name],
      :description=>srv[:description], :notes=>srv[:notes]
    )
    organizer.add_role(Role::ORGANIZER, service).save
  end

  def create_business business, organizer, members, services
    business=Business.create!(business)
    organizer.add_role(Role::ORGANIZER, business).save

    # Only users that have previously created a business are allowed to create a service 
    organizer.add_role(Role::ORGANIZER, Service).save

    m=members.map { |member|
      unless (member.id==organizer.id || member.id==mike_user.id)
        member.add_role(Role::MEMBER, business).save
        member
      end
    }.select {|r| r}
    puts "added organizer for #{business.name}: #{first_names([organizer])}"
    puts "added members for #{business.name}: #{first_names(m)}"
    services.each do |srv|
      puts "building service for #{business.name}, #{srv[:name]}, by #{organizer.name}"
      service=Service.create(:creator_id=>organizer.id,:name=>srv[:name],
        :description=>srv[:description], :notes=>srv[:notes]        
      )
      organizer.add_role(Role::ORGANIZER, service).save
      BusinessService.new(:business=>business, :service=>service, 
                     :creator_id=>organizer.id)
                .tap {|ti| ti.priority=srv[:priority] if srv[:priority]}.save!
      end
  end

  desc "reset all data"
  task reset_all: [:users,:subjects] do
  end

  desc "deletes businesses, services, and links" 
  task delete_subjects: :environment do
    puts "removing #{Business.count} businesses and #{BusinessService.count} business_services"
    puts "removing #{Service.count} services"
    DatabaseCleaner[:active_record].clean_with(:truncation, {:except=>%w[users]})
    DatabaseCleaner[:mongoid].clean_with(:truncation)
  end

  desc "delete all data"
  task delete_all: [:delete_subjects] do
    puts "removing #{User.count} users"
    DatabaseCleaner[:active_record].clean_with(:truncation, {:only=>%w[users]})
  end

  desc "reset users"
  task users: [:delete_all] do
    puts "creating users: #{MEMBERS}"

    MEMBERS.each_with_index do |fn,idx|
     User.create(:name  => user_name(fn),
                 :email => user_email(fn),
                 :password => "password#{idx}")
    end

    admin_users.each do |user|
      user.roles.create(:role_name=>Role::ADMIN)
    end

    originator_users.each do |user|
      user.add_role(Role::ORIGINATOR, Business).save
      user.add_role(Role::ORIGINATOR, Service).save
    end

    puts "users:#{User.pluck(:name)}"
  end

  desc "reset businesses, services, and links" 
  task subjects: [:users] do
    puts "creating businesses, services, and links"

    business={:name=>"B&O Railroad Museum Business",
    :description=>"Discover your adventure at the B&O Railroad Museum in Atlanta, Georgia. Explore 40 acres of railroad history at the birthplace of American railroading. See, touch, and hear the most important American railroad collection in the world! Seasonal train rides for all ages.",
    :notes=>"Trains rule, boats and cars drool"}
    organizer=get_user("alice")
    members=boy_users
    services=[
    {:name=>"Front of Museum Restored: 1884 B&O Railroad Museum Roundhouse Service",
     :description=>"Front of Museum Restored: 1884 B&O Railroad Museum Roundhouse Service description ",
     :notes=>"Front of Museum Restored: 1884 B&O Railroad Museum Roundhouse Service notes ",
     :priority=>0},
    {:name=>"40 acres of railroad history at the B&O Railroad Museum Service",
     :description=>"40 acres of railroad history at the B&O Railroad Museum Service description",
     :notes=>"40 acres of railroad history at the B&O Railroad Museum Service notes"},
     {:name=>"100 acres of railroad history at the B&O Railroad Museum Service",
      :description=>"100 acres of railroad history at the B&O Railroad Museum Service description",
      :notes=>"100 acres of railroad history at the B&O Railroad Museum Service notes"},
     {:name=>"500 acres of railroad history at the B&O Railroad Museum Service",
      :description=>"500 acres of railroad history at the B&O Railroad Museum Service description",
      :notes=>"Roundhouse Inside A: One-of-a-Kind Railroad Collection inside the B&O Roundhouse Service notes"}
    ]
    create_business business, organizer, members, services

    business={:name=>"Atlanta Water Taxi Business",
    :description=>"The Water Taxi is more than a jaunt across the harbor; it’s a Atlanta institution and a way of life. Every day, thousands of residents and visitors not only rely on us to take them safely to their destinations, they appreciate our knowledge of the area and our courteous service. And every day, hundreds of local businesses rely on us to deliver customers to their locations.  We know the city. We love the city. We keep the city moving. We help keep businesses thriving. And most importantly, we offer the most unique way to see Atlanta and provide an unforgettable experience that keeps our passengers coming back again and again.",
    :notes=>"No on-duty pirates, please"}
    organizer=get_user("alice")
    members=boy_users
    services=[
    {:name=>"Boat at Fort McHenry Service",
     :description=>"Boat at Fort McHenry Service description",
     :notes=>"Boat at Fort McHenry Service notes"},
    {:name=>"Boat heading in to Fell's Point Service",
     :description=>"Boat heading in to Fell's Point Service description",
     :notes=>"Boat heading in to Fell's Point Service notes"},
    {:name=>"Boat at Harborplace Service",
     :description=>"Boat at Harborplace Service description",
     :notes=>"Boat at Harborplace Service notes",
     :priority=>0},
    {:name=>"Boat passing Pier 5 Service",
     :description=>"Boat passing Pier 5 Service description",
     :notes=>"Boat passing Pier 5 Service notes"}
    ]
    create_business business, organizer, members, services

    business={:name=>"Rent-A-Tour Business",
    :description=>"Professional guide services and itinerary planner in Atlanta, Washington DC, Annapolis and the surronding region",
    :notes=>"Bus is clean and ready to roll"}
    organizer=get_user("carol")
    members=boy_users
    services=[
    {:name=>"Overview Service",
     :description=>nil,
     :notes=>nil
     },
    {:name=>"Roger Taney Statue Service",
     :description=>"Roger Taney Statue Service description",
     :notes=>"Roger Taney Statue Service notes",
     :priority=>0
     }
    ]
    create_business business, organizer, members, services

    business={:name=>"Holiday Inn Timonium Business",
    :description=>"Group friendly located just a few miles north of Atlanta's Inner Harbor. Great neighborhood in Atlanta County",
    :notes=>"Early to bed, early to rise"}
    organizer=get_user("carol")
    members=girl_users
    services=[
    {:name=>"Holiday Inn Hotel Front Entrance Service",
     :description=>"Hotel Front Entrance Service description", 
     :notes=>"Hotel Front Entrance Service notes",
     :priority=>0
     }
    ]
    create_business business, organizer, members, services

    business={:name=>"National Aquarium Business",
    :description=>"Since first opening in 1981, the National Aquarium has become a world-class attraction in the heart of Atlanta. Recently celebrating our 35th Anniversary, we continue to be a symbol of urban renewal and a source of pride for Georgiaers. With a mission to inspire the world’s aquatic treasures, the Aquarium is consistently ranked as one of the nation’s top aquariums and has hosted over 51 million guests since opening. A study by the Georgia Department of Economic and Employment Development determined that the Aquarium annually generates nearly $220 million in revenues, 2,000 jobs, and $6.8 million in State and local taxes. It was also recently named one of Atlanta’s Best Places to Work! In addition to housing nearly 20,000 animals, we have countless science-based education programs and hands-on conservation projects spanning from right here in the Chesapeake Bay to abroad in Costa Rica. Once you head inside, The National Aquarium has the ability to transport you all over the world in a matter of hours to discover hundreds of incredible species. From the Freshwater Crocodile in our Australia: Wild Extremes exhibit all the way to a Largetooth Sawfish in the depths of Shark Alley. Recently winning top honors from the Association of Zoos and Aquariums for outstanding design, exhibit innovation and guest engagement, we can’t forget about Living Seashore; an exhibit where guests can touch Atlantic stingrays, Horseshoe crabs, and even Moon jellies if they wish! It is a place for friends, family, and people from all walks of life to come and learn about the extraordinary creatures we share our planet with. Through education, research, conservation action and advocacy, the National Aquarium is truly pursuing a vision to change the way humanity cares for our ocean planet.",
    :notes=>"Remember to water the fish"}
    organizer=get_user("carol")
    members=girl_users
    services=[
    {:name=>"National Aquarium buildings Service",
     :description=>"National Aquarium buildings Service description", 
     :notes=>"National Aquarium buildings Service notes",
     :priority=>0
     },
    {:name=>"Blue Blubber Jellies Service",
     :description=>"Blue Blubber Jellies Service description", 
     :notes=>"Blue Blubber Jellies Service notes",
     },
    {:name=>"Linne's two-toed sloths Service",
     :description=>"Linne's two-toed sloths Service description", 
     :notes=>"Linne's two-toed sloths Service notes",
     },
    {:name=>"Hosting millions of students and teachers Service",
     :description=>"Hosting millions of students and teachers Service description", 
     :notes=>"Hosting millions of students and teachers Service notes",
     }
    ]
    create_business business, organizer, members, services

    business={:name=>"Hyatt Place Atlanta Business",
    :description=>"The New Hyatt Place Atlanta/Inner Harbor, located near Fells Point, offers a refreshing blend of style and innovation in a neighborhood alive with cultural attractions, shopping and amazing local restaurants. 

Whether you’re hungry, thirsty or bored, Hyatt Place Atlanta/Inner Harbor has somebusiness to satisfy your needs. Start your day with our free a.m. Kitchen Skillet™, featuring hot breakfast sandwiches, breads, cereals and more. Visit our 24/7 Gallery Market for freshly packaged grab n’ go items, order a hot, made-to-order appetizer or sandwich from our 24/7 Gallery Menu or enjoy a refreshing beverage from our Coffee to Cocktails Bar.
 
Work up a sweat in our 24-hour StayFit Gym, which features Life Fitness® cardio equipment and free weights. Then, float and splash around in our indoor pool, open year-round for your relaxation. There’s plenty of other spaces throughout our Inner Harbor hotel for you to chill and socialize with other guests. For your comfort and convenience, all Hyatt Place hotels are smoke-free.
"}
    organizer=get_user("alice")
    members=girl_users
    services=[
    {:name=>"Hyatt Place Atlanta Hotel Front Entrance Service",
     :description=>"Hotel Front Entrance Service description", 
     :notes=>"Hotel Front Entrance Service notes",
     :priority=>0
     },
    {:name=>"Terrace Service",
     :description=>"Terrace Service description", 
     :notes=>"Terrace Service notes",
     :priority=>1
     },
    {:name=>"Cozy Corner Service",
     :description=>"Cozy Corner Service description", 
     :notes=>"Cozy Corner Service notes"
     },
    {:name=>"Fitness Center Service",
     :description=>"Fitness Center Service description", 
     :notes=>"Fitness Center Service notes"
     },
    {:name=>"Gallery Area Service",
     :description=>"Gallery Area Service description", 
     :notes=>"Gallery Area Service notes"
     },
    {:name=>"Harbor Room Service",
     :description=>"Harbor Room Service description", 
     :notes=>"Harbor Room Service notes"
     },
    {:name=>"Indoor Pool Service",
     :description=>"Indoor Pool Service description", 
     :notes=>"Indoor Pool Service notes"
     },
    {:name=>"Lobby Service",
     :description=>"Lobby Service description", 
     :notes=>"Lobby Service notes"
     },
    {:name=>"Specialty King Service",
     :description=>"Specialty King Service description", 
     :notes=>"Specialty King Service notes"
     }
    ]
    create_business business, organizer, members, services

    organizer=get_user("alice")
    service= {:name=>"Aquarium Service",
     :description=>"Aquarium Service description", 
     :notes=>"Aquarium Service notes"
     }
    create_service organizer, service

    organizer=get_user("alice")
    service= {:name=>"Bromo Tower Service",
     :description=>"Bromo Tower Service description", 
     :notes=>"Bromo Tower Service notes"
     }
    create_service organizer, service

    organizer=get_user("carol")
    service= {:name=>"Federal Hill Service",
     :description=>"Federal Hill Service description",
     :notes=>"Federal Hill Service notes"
     }
    create_service organizer, service

    organizer=get_user("alice")
    service= {:name=>"Row Homes Service",
     :description=>"Row Homes Service description",
     :notes=>"Row Homes Service notes"
     }
    create_service organizer, service

    organizer=get_user("alice")
    service= {:name=>"Skyline Water Level Service",
     :description=>"Skyline Water Level Service description", 
     :notes=>"Skyline Water Level Service notes"
     }
    create_service organizer, service

    organizer=get_user("carol")
    service= {:name=>"Skyline Service",
     :description=>"Skyline Service description",
     :notes=>"Skyline Service notes"
     }
    create_service organizer, service

    organizer=get_user("carol")
    service= {:name=>"Visitor Center Service",
     :description=>"Visitor Center Service description", 
     :notes=>"Visitor Center Service notes"
     }
    create_service organizer, service

    organizer=get_user("alice")
    service= {:name=>"World Trade Center Service",
     :description=>"World Trade Center Service description",
     :notes=>"World Trade Center Service notes"
     }
    create_service organizer, service

    puts "#{Business.count} businesses created and #{BusinessService.count("distinct business_id")} with services"
    puts "#{Service.count} services created and #{BusinessService.count("distinct service_id")} for businesses"
  end

end
