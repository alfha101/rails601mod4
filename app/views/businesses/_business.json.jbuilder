# I removed notes from this top section 
# json.extract! business, :id, :name, :description, :notes,  :created_at, :updated_at
json.extract! business, :id, :name, :description, :created_at, :updated_at
# ... and brought it into its own section, and then latched it to say restrict notes.
json.notes business.notes   unless restrict_notes? business.user_roles
json.url business_url(business, format: :json)
# we want to display some roles, unless those roles are empty
json.user_roles business.user_roles    unless business.user_roles.empty?
