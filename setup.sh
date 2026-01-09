#!/bin/bash

# Digital Signage - Complete Setup Script

echo "🚀 Digital Signage Setup Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if PostgreSQL is installed
echo "📦 Checking prerequisites..."
if ! command -v psql &> /dev/null; then
    echo -e "${RED}❌ PostgreSQL is not installed${NC}"
    echo "Please install PostgreSQL first:"
    echo "  macOS: brew install postgresql"
    echo "  Ubuntu: sudo apt-get install postgresql"
    exit 1
fi

if ! command -v go &> /dev/null; then
    echo -e "${RED}❌ Go is not installed${NC}"
    echo "Please install Go from https://golang.org/dl/"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites OK${NC}"
echo ""

# Setup Backend
echo "🔧 Setting up Backend..."
cd backend

# Create .env if not exists
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Please edit backend/.env with your database credentials${NC}"
fi

# Download Go dependencies
echo "Downloading Go dependencies..."
go mod download

# Create uploads directory
mkdir -p uploads

echo -e "${GREEN}✅ Backend setup complete${NC}"
echo ""

# Setup Database
echo "🗄️  Setting up Database..."
read -p "Do you want to create the database? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter database name [digital_signage]: " DB_NAME
    DB_NAME=${DB_NAME:-digital_signage}
    
    echo "Creating database $DB_NAME..."
    createdb $DB_NAME 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Database created successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Database might already exist${NC}"
    fi
fi
echo ""

# Setup Flutter
echo "📱 Setting up Flutter App..."
cd ..

if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter is not installed${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "Getting Flutter dependencies..."
flutter pub get

echo -e "${GREEN}✅ Flutter setup complete${NC}"
echo ""

# Summary
echo "✨ Setup Complete!"
echo "=================="
echo ""
echo "Next steps:"
echo ""
echo "1. Edit backend/.env with your configuration"
echo ""
echo "2. Start the backend server:"
echo "   cd backend"
echo "   go run main.go"
echo ""
echo "3. In a new terminal, run the Flutter app:"
echo "   flutter run"
echo ""
echo "4. For API documentation, check backend/README.md"
echo ""
echo "📚 Read MIGRATION_GUIDE.md for detailed information"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
