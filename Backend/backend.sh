#!/bin/bash

# Update package list
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Install Node.js and npm
sudo apt-get install -y nodejs npm

# Clone your backend project from your repository
# git clone https://github.com/your-repo/your-backend-project.git /home/ubuntu/my-backend-project

# Navigate to the project directory
cd /home/ubuntu/my-backend-project

# Install project dependencies
npm install

# Start the backend application
node app.js