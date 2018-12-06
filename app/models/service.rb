class Service < ActiveRecord::Base
  include Protectable
  validates :name, :presence=>true

  has_many :business_services, inverse_of: :service, dependent: :destroy
  # has_many :businesses, through: :business_services

  scope :not_linked, ->(business) { where.not(:id=>BusinessService.select(:service_id)
  .where(:business=>business)) }

end


