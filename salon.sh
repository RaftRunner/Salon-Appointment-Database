#!/bin/bash

# Connect to the salon database
PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Function to display services
display_services() {
  echo "$($PSQL "SELECT service_id, name FROM services")" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
}

# Main script
main() {
  echo "Welcome to My Salon, how can I help you?"

  # Display services
  display_services

  # Prompt for service selection
  read SERVICE_ID_SELECTED
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

  # Check if service exists
  if [[ -z $SERVICE_NAME ]]
  then
    echo "Invalid service. Please select a valid service."
    main
  else
    # Prompt for phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # If customer does not exist, prompt for name and insert into customers table
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi

    # Get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    # Prompt for appointment time
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    # Insert appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # Confirm appointment
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Run the main function
main
