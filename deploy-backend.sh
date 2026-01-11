#!/bin/bash

# Digital Signage Backend Deployment Script
# Run this script on your Ubuntu server

set -e

echo "🚀 Starting Digital Signage Backend Deployment..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="digital-signage-backend"
APP_DIR="/home/otobook/adstab"
SERVICE_NAME="digital-signage-backend.service"
DB_NAME="digital_signage"
DB_USER="adstab_user"
DB_PASSWORD="adstab_password_2026"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running as root or with sudo
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root. Please run as regular user with sudo access."
   exit 1
fi

# Update system
print_status "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install Go
print_status "Installing Go..."
sudo apt install -y golang-go

# Verify Go installation
if ! command -v go &> /dev/null; then
    print_error "Go installation failed"
    exit 1
fi

print_status "Go version: $(go version)"

# Install Git if not present
if ! command -v git &> /dev/null; then
    print_status "Installing Git..."
    sudo apt install -y git
fi

# Create application directory
print_status "Creating application directory..."
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# Copy backend files (you need to upload these files first)
# Assuming you have uploaded: main.go, go.mod, go.sum, and all source files

# Download dependencies
print_status "Downloading Go dependencies..."
go mod download

# Build the application
print_status "Building backend binary..."
GOOS=linux GOARCH=amd64 go build -o "$APP_NAME" main.go

# Create uploads directory
print_status "Creating uploads directory..."
mkdir -p uploads

# Setup MySQL database
print_status "Setting up MySQL database..."

# Create database user
sudo mysql -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASSWORD';"

# Create database
sudo mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME;"

# Grant privileges
sudo mysql -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

print_status "Database setup completed"

# Copy environment file
print_status "Setting up environment configuration..."
cp .env.production .env

# Create systemd service
print_status "Creating systemd service..."

SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Digital Signage Backend Service
After=network.target mysql.service
Requires=mysql.service

[Service]
Type=simple
User=otobook
WorkingDirectory=$APP_DIR
ExecStart=$APP_DIR/$APP_NAME
Restart=always
RestartSec=5
Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable service
print_status "Enabling and starting service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

# Check service status
sleep 3
if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
    print_status "✅ Service started successfully!"
    print_status "Service status:"
    sudo systemctl status "$SERVICE_NAME" --no-pager -l
else
    print_error "❌ Service failed to start"
    print_status "Checking service logs:"
    sudo journalctl -u "$SERVICE_NAME" --no-pager -n 20
    exit 1
fi

# Setup firewall (optional)
print_status "Setting up firewall..."
sudo ufw allow 8080/tcp || print_warning "UFW not available or already configured"

# Print deployment summary
echo ""
echo "🎉 Deployment completed successfully!"
echo ""
echo "📋 Summary:"
echo "   - Application: $APP_NAME"
echo "   - Directory: $APP_DIR"
echo "   - Service: $SERVICE_NAME"
echo "   - Port: 8080"
echo "   - Database: $DB_NAME"
echo ""
echo "🔗 API will be available at: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
echo "📝 Useful commands:"
echo "   - Check status: sudo systemctl status $SERVICE_NAME"
echo "   - View logs: sudo journalctl -u $SERVICE_NAME -f"
echo "   - Restart: sudo systemctl restart $SERVICE_NAME"
echo "   - Stop: sudo systemctl stop $SERVICE_NAME"
echo ""
echo "⚠️  Remember to:"
echo "   - Update your Flutter app API config to point to the server IP"
echo "   - Configure proper firewall rules for production"
echo "   - Set up SSL/HTTPS if needed"
echo "   - Backup your database regularly"