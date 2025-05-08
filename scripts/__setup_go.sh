#!/bin/bash

# Check if project name is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <project_name>"
    exit 1
fi

PROJECT_NAME=$1

# Create main project directory
mkdir -p $PROJECT_NAME
cd $PROJECT_NAME

# Create directory structure
mkdir -p cmd/$PROJECT_NAME internal/{api,models,services,config} pkg/utils

# Create main.go
cat << EOF > cmd/$PROJECT_NAME/main.go
package main

import (
    "fmt"
    "log"
    "github.com/username/$PROJECT_NAME/internal/api"
    "github.com/username/$PROJECT_NAME/internal/config"
    "github.com/username/$PROJECT_NAME/internal/services"
)

func main() {
    fmt.Println("$PROJECT_NAME started")
    // TODO: Implement main logic
}
EOF

# Create api_client.go
cat << EOF > internal/api/api_client.go
package api

type APIClient struct {
    // TODO: Implement API client
}
EOF

# Create model.go
cat << EOF > internal/models/model.go
package models

type Model struct {
    // TODO: Define model structure
}
EOF

# Create service.go
cat << EOF > internal/services/service.go
package services

type Service struct {
    // TODO: Implement service
}
EOF

# Create config.go
cat << EOF > internal/config/config.go
package config

type Config struct {
    // TODO: Define configuration structure
}

func Load() (*Config, error) {
    // TODO: Implement configuration loading
    return nil, nil
}
EOF

# Create utils.go
cat << EOF > pkg/utils/utils.go
package utils

// TODO: Implement utility functions
EOF

# Initialize Go module
go mod init github.com/username/$PROJECT_NAME

# Create config.yaml
cat << EOF > config.yaml
# TODO: Add configuration parameters
EOF

echo "$PROJECT_NAME project structure created successfully!"
