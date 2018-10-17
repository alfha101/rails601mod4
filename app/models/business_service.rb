class BusinessService < ActiveRecord::Base
  belongs_to :service
  belongs_to :business

  validates :service, :business, presence: true

  scope :prioritized,  -> { order(:priority=>:asc) }
  scope :businesses,       -> { where(:priority=>0) }
  scope :primary,      -> { where(:priority=>0).first }

  scope :with_name,    ->{ joins(:business).select("business_services.*, businesses.name as business_name")}
  scope :with_sname, ->{ joins(:service).select("business_services.*, services.name as service_name")}
end
