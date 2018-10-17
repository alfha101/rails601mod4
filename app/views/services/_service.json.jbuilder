json.extract! service, :id, :name, :description, :notes, :creator_id, :created_at, :updated_at
json.url service_url(service, format: :json)
json.user_roles service.user_roles      unless service.user_roles.empty?
