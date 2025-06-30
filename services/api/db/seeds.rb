# Create tenant first
Tenant.create!(
  name: "Trackc",
  code: "ACC-TRACKC-FCd1Zm"
)

# Load all role types
require_relative 'seeds/administrator_roles'
require_relative 'seeds/union_roles'
require_relative 'seeds/non_union_roles'
