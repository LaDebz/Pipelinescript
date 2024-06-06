#!/bin/bash
set -e

# Optionally set the AWS CLI profile to use (default if not specified)
AWS_PROFILE=${AWS_PROFILE:-default}

# Function to stop EC2 instances
stop_instances() {
  echo "Stopping all running EC2 instances..."
  INSTANCE_IDS=$(aws ec2 describe-instances --profile $AWS_PROFILE --query 'Reservations[*].Instances[?State.Name==`running`].InstanceId' --output text)
  if [ -n "$INSTANCE_IDS" ]; then
    aws ec2 stop-instances --instance-ids $INSTANCE_IDS --profile $AWS_PROFILE
    echo "Instances stopped: $INSTANCE_IDS"
  else
    echo "No running instances to stop."
  fi
}

# Function to start EC2 instances
start_instances() {
  echo "Starting all stopped EC2 instances..."
  INSTANCE_IDS=$(aws ec2 describe-instances --profile $AWS_PROFILE --query 'Reservations[*].Instances[?State.Name==`stopped`].InstanceId' --output text)
  if [ -n "$INSTANCE_IDS" ]; then
    aws ec2 start-instances --instance-ids $INSTANCE_IDS --profile $AWS_PROFILE
    echo "Instances started: $INSTANCE_IDS"
  else
    echo "No stopped instances to start."
  fi
}

# Get current hour and minute in UTC
HOUR=$(date -u +"%H")
MINUTE=$(date -u +"%M")

# Stop instances at 18:00 UTC (6 PM)
if [ "$HOUR" -eq 18 ] && [ "$MINUTE" -eq 00 ]; then
  stop_instances
fi

# Start instances if the time is 23:50 UTC or later
if [ "$HOUR" -gt 23 ] || { [ "$HOUR" -eq 23 ] && [ "$MINUTE" -ge 50 ]; }; then
  start_instances
fi
