#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# List of developer emails
DEVELOPERS=(
    "michael@nicest.ai"
    "karthik@drylogics.com"
    "santhosh@drylogics.com"
    "sathya.arunachalam@drylogics.com"
    #"priyadharshini@drylogics.com"
    #"gopinath@drylogics.com"
    #"arunkumar@drylogics.com"
    #"saravanan.v@drylogics.com"
    #"prasanna@drylogics.com"
    #"yuvaraj@drylogics.com"
)

# Function to extract username from email
get_username() {
    local email=$1
    echo "$email" | cut -d@ -f1
}

# Process each developer
for email in "${DEVELOPERS[@]}"; do
    username=$(get_username "$email")
    echo "Adding developer: $username ($email)"
    "${SCRIPT_DIR}/add_developer.sh" "$email" "$username" "dev"
done

echo "All developers have been added!"