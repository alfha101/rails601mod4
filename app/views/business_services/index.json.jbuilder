json.array!(@business_services) do |ti|
    json.extract! ti, :id, :business_id, :service_id, :priority, :creator_id, :created_at, :updated_at
    json.business_name ti.business_name        if ti.respond_to?(:business_name)
    json.service_name ti.service_name  if ti.respond_to?(:service_name)
  end