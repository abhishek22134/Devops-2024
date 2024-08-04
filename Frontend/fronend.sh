#!/bin/bash

# Update and install necessary packages
sudo apt-get update -y
sudo apt-get install -y docker.io

# Start Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Pull the Docker image from DockerHub
sudo docker pull abhishekjyethi/frontend-app

# Run the Docker container
sudo docker run --name frontend-container -p 80:80 -d abhishekjyethi/frontend-app