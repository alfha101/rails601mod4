class Business < ActiveRecord::Base
    include Protectable
    validates :name, :presence=>true
  
    has_many :business_services, inverse_of: :business, dependent: :destroy
  
    scope :not_linked, ->(service) { where.not(:id=>BusinessService.select(:business_id)
    .where(:service=>service)) }
  
end
