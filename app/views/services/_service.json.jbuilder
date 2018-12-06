# I removed notes from this top section 
json.extract! service, :id, :name, :description, :created_at, :updated_at
# ... and brought it into its own section, and then latched it to say restrict notes.
json.notes service.notes   unless restrict_notes? service.user_roles
json.url service_url(service, format: :json)

# we want to display some roles, unless those roles are empty
json.user_roles service.user_roles    unless service.user_roles.empty?

